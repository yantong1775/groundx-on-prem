env = dict(
    deviceType="${deviceType}",
    searchBroker="redis://${cacheAddr}:${cachePort}/0",
    searchResultBroker="redis://${cacheAddr}:${cachePort}/0",
    searchLog="${rankerService}",
    searchMaxPromptLength=${rankerMaxPrompt},
    searchModelName="${rankerModelName}",
    validAPIKeys=["${validAPIKey}", "${validUsername}"],
)
