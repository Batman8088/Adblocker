#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <netdb.h>
#import <substrate.h>

// ==========================================
// 1. GOOGLE ADMOB & FIREBASE ANALYTICS
// ==========================================
%hook GADBannerView
- (void)loadRequest:(id)request { return; }
%end

%hook GADInterstitialAd
+ (void)loadWithAdUnitID:(id)adUnitID request:(id)request completionHandler:(id)completionHandler { return; }
%end

%hook GADRewardedAd
+ (void)loadWithAdUnitID:(id)adUnitID request:(id)request completionHandler:(id)completionHandler { return; }
%end

%hook GADAppOpenAd
+ (void)loadWithAdUnitID:(id)adUnitID request:(id)request orientation:(UIInterfaceOrientation)orientation completionHandler:(id)completionHandler { return; }
%end

// Firebase Analytics & Crashlytics Telemetry
%hook FIRAnalytics
+ (void)logEventWithName:(NSString *)name parameters:(NSDictionary *)parameters { return; }
+ (void)setUserPropertyString:(NSString *)value forName:(NSString *)name { return; }
+ (void)setUserID:(NSString *)userID { return; }
%end

%hook FIRCrashlytics
- (void)log:(NSString *)msg { return; }
- (void)recordError:(NSError *)error { return; }
%end

// ==========================================
// 2. APPLOVIN, UNITY, IRONSOURCE, VUNGLE, CHARTBOOST
// ==========================================
%hook MAAdView
- (void)loadAd { return; }
%end

%hook MAInterstitialAd
- (void)loadAd { return; }
- (void)showAd { return; }
%end

%hook MARewardedAd
- (void)loadAd { return; }
- (void)showAd { return; }
%end

%hook UnityAds
+ (void)load:(NSString *)placementId { return; }
+ (void)load:(NSString *)placementId options:(id)options loadDelegate:(id)loadDelegate { return; }
+ (void)show:(UIViewController *)viewController placementId:(NSString *)placementId { return; }
%end

%hook UADSBannerView
- (void)load { return; }
%end

%hook IronSource
+ (void)loadBannerWithViewController:(UIViewController *)viewController size:(id)size { return; }
+ (void)loadInterstitial { return; }
+ (void)showInterstitialWithViewController:(UIViewController *)viewController { return; }
+ (void)showRewardedVideoWithViewController:(UIViewController *)viewController { return; }
%end

%hook VungleBanner
- (void)load:(NSString *)adm { return; }
%end

%hook VungleInterstitial
- (void)load:(NSString *)adm { return; }
%end

%hook CHBInterstitial
- (void)cache { return; }
- (void)showFromViewController:(UIViewController *)viewController { return; }
%end

// ==========================================
// 3. META (FACEBOOK) ADS & APP EVENTS TRACKER
// ==========================================
%hook FBAdView
- (void)loadAd { return; }
%end

%hook FBInterstitialAd
- (void)loadAd { return; }
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController { return NO; }
%end

%hook FBSDKAppEvents
+ (void)logEvent:(NSString *)eventName { return; }
+ (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters { return; }
+ (void)logPurchase:(double)purchaseAmount currency:(NSString *)currency { return; }
+ (void)activateApp { return; }
%end

// ==========================================
// 4. ATTRIBUTION & ANALYTICS SDKs (AppsFlyer, Adjust, Mixpanel, Amplitude, Sentry, Branch)
// ==========================================
%hook AppsFlyerLib
- (void)start { return; }
- (void)logEvent:(NSString *)eventName withValues:(NSDictionary *)values { return; }
%end

%hook Adjust
+ (void)appDidLaunch:(id)adjustConfig { return; }
+ (void)trackEvent:(id)event { return; }
%end

%hook MixpanelInstance
- (void)track:(NSString *)event properties:(NSDictionary *)properties { return; }
- (void)identify:(NSString *)distinctId { return; }
%end

%hook Amplitude
- (void)logEvent:(NSString *)eventType withEventProperties:(NSDictionary *)eventProperties { return; }
%end

%hook SentrySDK
+ (void)startWithConfigureOptions:(id)options { return; }
+ (void)captureEvent:(id)event { return; }
%end

%hook Branch
- (void)initSessionWithLaunchOptions:(NSDictionary *)options andRegisterDeepLinkHandler:(id)callback { return; }
%end

// ==========================================
// 5. UNIFIED AD & TRACKER DOMAIN BLOCKLIST
// ==========================================
static BOOL isBlockedHost(NSString *hostString) {
    if (!hostString || hostString.length == 0) return NO;
    NSString *host = hostString.lowercaseString;
    
    static NSArray *blockedDomains = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blockedDomains = @[
            // --- AD NETWORKS ---
            @"doubleclick.net", @"googlesyndication.com", @"googleadservices.com", @"admob.com",
            @"applovin.com", @"applvn.com",
            @"://unity3d.com", @"://unity3d.com",
            @"ironsrc.com", @"supersonicads.com",
            @"://facebook.com",
            @"vungle.com", @"liftoff.io",
            @"chartboost.com", @"tapjoy.com", @"tapjoyads.com",
            @"inmobi.com", @"mintegral.com", @"rayjump.com",
            @"pangleglobal.com", @"pangle.io",
            @"fyber.com", @"adcolony.com", @"mopub.com", @"smaato.net", @"pubmatic.com", @"criteo.com",
            
            // --- MOBILE ATTRIBUTION & AD TRACKERS ---
            @"appsflyer.com", @"appsflyersdk.com",
            @"adjust.com", @"adjust.io",
            @"branch.io", @"app.link",
            @"kochava.com",
            @"singular.net",
            @"tenjin.io", @"tenjin.com",
            
            // --- ANALYTICS, TELEMETRY & CRASH LOGGING ---
            @"app-measurement.com", @"google-analytics.com", @"://crashlytics.com", @"crashlytics.com",
            @"mixpanel.com",
            @"amplitude.com",
            @"segment.io", @"segment.com",
            @"sentry.io",
            @"bugsnag.com",
            @"instabug.com",
            @"flurry.com",
            @"braze.com", @"appboy.com",
            @"clevertap.com",
            @"onesignal.com",
            @"urbanairship.com",
            @"datadoghq.com",
            @"newrelic.com",
            @"scorecardresearch.com",
            @"omtrdc.net", @"demdex.net" // Adobe Analytics
        ];
    });
    
    for (NSString *domain in blockedDomains) {
        if ([host isEqualToString:domain] || [host hasSuffix:[@"." stringByAppendingString:domain]]) {
            return YES;
        }
    }
    return NO;
}

// ==========================================
// 6. HIGH-LEVEL (NSURLSession) & LOW-LEVEL (C getaddrinfo) BLOCKING
// ==========================================
%hook NSURLSession
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    if (isBlockedHost(request.URL.host)) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil];
            completionHandler(nil, nil, error);
        }
        return nil;
    }
    return %orig;
}

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    if (isBlockedHost(url.host)) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil];
            completionHandler(nil, nil, error);
        }
        return nil;
    }
    return %orig;
}
%end

// Hook C-level DNS resolution to catch C++, Unity, and custom socket trackers
static int (*orig_getaddrinfo)(const char *, const char *, const struct addrinfo *, struct addrinfo **);

static int replaced_getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res) {
    if (node != NULL) {
        NSString *host = [NSString stringWithUTF8String:node];
        if (isBlockedHost(host)) {
            return EAI_NONAME; // Fail DNS lookup immediately
        }
    }
    return orig_getaddrinfo(node, service, hints, res);
}

%ctor {
    %init;
    MSHookFunction((void *)getaddrinfo, (void *)replaced_getaddrinfo, (void **)&orig_getaddrinfo);
}
