#  Using swift code from react-native

1. Uncomment this lines in Podfile

=============================================================================================================
#require_relative '../node_modules/react-native/scripts/react_native_pods'
#require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'
=============================================================================================================
#  config = use_native_modules!

#  use_react_native!(
#    :path => config[:reactNativePath],
#    # to enable hermes on iOS, change `false` to `true` and then install pods
#    :hermes_enabled => false
#  )

=============================================================================================================

#  post_install do |installer|
#    react_native_post_install(installer)
#    __apply_Xcode_12_5_M1_post_install_workaround(installer)
#  end
=============================================================================================================



2. Add RCTBridge.m to test-pytorch-ios target
3. Add RCTModule.swift to test-pytorch-ios target 
4. Uncomment second line in test-pytorch-ios-Bridging-Header.h 
//#import <React/RCTBridgeModule.h>

