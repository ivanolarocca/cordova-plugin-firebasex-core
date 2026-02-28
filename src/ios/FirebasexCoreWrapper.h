#import <FirebaseCore/FirebaseCore.h>

#if !defined(__has_include)
  #error "FirebasexCoreWrapper.h won't import anything if your compiler doesn't support __has_include."
#else
  #if __has_include(<FirebaseInstallations/FirebaseInstallations.h>)
    #import <FirebaseInstallations/FirebaseInstallations.h>
  #endif
#endif
