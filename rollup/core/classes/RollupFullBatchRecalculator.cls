public without sharing virtual class RollupFullBatchRecalculator extends RollupFullRecalcProcessor implements Database.Stateful {
  private final Map<String, CalcItemBag> statefulLookupToCalcItems;

  public RollupFullBatchRecalculator(
    String queryString,
    InvocationPoint invokePoint,
    List<Rollup__mdt> rollupInfo,
    SObjectType calcItemType,
    Set<String> recordIds,
    RollupFullRecalcProcessor postProcessor
  ) {
    super(queryString, invokePoint, rollupInfo, calcItemType, recordIds, postProcessor);
    this.statefulLookupToCalcItems = new Map<String, CalcItemBag>();
  }

  public override Database.QueryLocator start(Database.BatchableContext bc) {
    this.isProcessed = true;
    // note - if the optional where clause was appended to the passed in query string,
    // this.recordIds is also used as a bind variable
    return Database.getQueryLocator(RollupQueryBuilder.Current.getAllRowSafeQuery(this.calcItemType, this.queryString));
  }

  public virtual override void execute(Database.BatchableContext bc, List<SObject> calcItems) {
    RollupLogger.Instance.log('starting full batch recalc run:', this, LoggingLevel.DEBUG);
    /**
     * this batch class is a glorified "for loop" for the calc items, dispatching
     * them to the overall Rollup framework while breaking us out of the query limits
     * it has to be it's own class - Database.Batchable does not support inner classes
     * being batched, even if the inner class is just extending the functionality of its
     * parent class
     */
    this.getDelegatedFullRecalcRollup(this.rollupInfo, calcItems, this)?.runCalc();
    RollupLogger.Instance.save();
  }

  public override void finish(Database.BatchableContext bc) {
    if (this.isTimingOut == false) {
      this.fullRecalcProcessor?.finish();
    }
    RollupLogger.Instance.log(this.getTypeName() + ' finished', LoggingLevel.DEBUG);
    RollupLogger.Instance.save();
  }

  protected virtual override String getTypeName() {
    return RollupFullBatchRecalculator.class.getName();
  }

  protected virtual override String startAsyncWork() {
    return this.startBatchProcessor();
  }

  protected override void retrieveAdditionalCalcItems(
    Map<String, CalcItemBag> lookupToCalcItems,
    RollupAsyncProcessor rollup,
    Map<String, List<SObject>> localCachedFullRecalcs
  ) {
    Map<String, CalcItemBag> lookupKeysThatNeedFilling = new Map<String, CalcItemBag>();
    for (String lookupKey : lookupToCalcItems.keySet()) {
      CalcItemBag bag = lookupToCalcItems.get(lookupKey);
      if (this.statefulLookupToCalcItems.containsKey(lookupKey)) {
        lookupToCalcItems.put(lookupKey, this.statefulLookupToCalcItems.get(lookupKey));
      } else {
        lookupKeysThatNeedFilling.put(lookupKey, bag);
      }
    }

    super.retrieveAdditionalCalcItems(lookupKeysThatNeedFilling, rollup, localCachedFullRecalcs);

    for (String lookupKey : lookupKeysThatNeedFilling.keySet()) {
      CalcItemBag bag = lookupKeysThatNeedFilling.get(lookupKey);
      this.statefulLookupToCalcItems.put(lookupKey, bag);
      lookupToCalcItems.put(lookupKey, bag);
      this.recordIds.add(lookupKey);
    }
  }
}
