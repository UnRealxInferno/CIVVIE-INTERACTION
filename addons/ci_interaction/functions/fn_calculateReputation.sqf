/*
    Calculate Reputation (Addon)
    Returns descriptive text for current CI_PlayerReputation
*/
private _r = (CI_PlayerReputation max 1) min 100;
private _status = switch (true) do {
    case (_r >= 80): {"Hero - Civilians trust you completely (90% intel success)"};
    case (_r >= 60): {"Trusted - Civilians are willing to help (70% intel success)"};
    case (_r >= 40): {"Neutral - Civilians are cautious but civil (50% intel success)"};
    case (_r >= 20): {"Suspicious - Civilians are wary of you (30% intel success)"};
    default {"Hostile - Civilians fear and distrust you (10% intel success)"};
};
_status
