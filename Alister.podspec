

Pod::Spec.new do |s|

    s.name             = 'Alister'
    s.version          = '0.1.0'
    s.summary          = 'Table Helper'
    s.description      = 'Table and Collection Helper'
    s.homepage         = 'https://github.com/anodamobi/Alister'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Oksana Kovalchuk' => 'oksana@anoda.mobi' }
    s.source           = { :git => 'https://github.com/anodamobi/Alister.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/oks_ios'
    s.requires_arc     = true
    s.ios.deployment_target = '8.0'

    s.subspec 'ANKeyboardHandler' do |sp|
        sp.source_files = 'Alister/ANKeyboardHandler'
    end

    s.subspec 'ANStorage' do |sp|
        sp.source_files = 'Alister/ANStorage/**/*.{h,m}', 'Alister/ANStorage/**/**/*.{h,m}', 'Alister/ANStorage/**/**/**/*.{h,m}'
    end

    s.subspec 'ANListController' do |sp|
        sp.source_files = 'Alister/ANListController/**/*.{h,m}'
        sp.dependency 'Alister/ANStorage'
        sp.dependency 'Alister/ANKeyboardHandler'
    end
    
    s.subspec 'ANPrototypingUIKit' do |sp|
        sp.source_files = 'Alister/ANPrototypingUIKit/**/*.{h,m}',
                          'Alister/ANPrototypingUIKit/**/**/*.{h,m}'
        sp.dependency 'Alister/ANListController'
        sp.dependency 'Alister/ANKeyboardHandler'
        sp.dependency 'Masonry'
    end

end
