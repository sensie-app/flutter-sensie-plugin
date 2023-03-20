import Foundation
import SensieFramework

@objc public class Wrapper: NSObject {
    @objc public func callGlobalWhipCounter(param: NSDictionary) -> NSDictionary {
        return SensieFramework.whipCounter(param: param);
    }
    
    @objc public func callGlobalSignalStrength(sensies: [NSDictionary]) -> NSNumber{
        return SensieFramework.signalStrength(sensies: sensies);
    }
    
    @objc public func callGlobalEvaluateSensie(sensie: NSDictionary, sensies: [NSDictionary]) -> NSDictionary{
        return SensieFramework.evaluateSensie(sensie: sensie, sensies: sensies);
    }
}
