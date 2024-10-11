env = dict(
    deviceType="${deviceType}",
    summaryBroker="redis://${cacheAddr}:${cachePort}/0",
    summaryResultBroker="redis://${cacheAddr}:${cachePort}/0",
    summaryLog="${summaryService}",
    validAPIKeys=["${validAPIKey}", "${validUsername}"],
)
