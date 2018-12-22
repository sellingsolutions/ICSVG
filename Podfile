source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'

inhibit_all_warnings!
use_frameworks!

abstract_target 'SVG' do
    workspace 'ICSVG'
    project 'ICSVG'

    # Watch your language!
    pod 'SwiftLint'

    # UI TESTS
    target 'ICSVGUITests' do
        pod 'KIF', :configurations => ['Debug']
    end

    # UNIT TESTS
    target 'ICSVGTests' do
    end

end
