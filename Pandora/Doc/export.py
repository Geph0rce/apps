import os

productName = 'Zen'
projectName = '/Users/roger/github/Zen/Client/Zen/Zen.xcodeproj'
schemeName = 'Zen'
provisionName = 'Zen_Distribution'
buildPath = '~/Desktop/build/'
archiveName = buildPath + productName + '.xcarchive'
ipaName = buildPath + productName

# clean
clean_cmd = 'xcodebuild clean -project ' + projectName + ' -configuration Release -alltargets'
os.system(clean_cmd)

# archive
archive_cmd = 'xcodebuild archive -project ' + projectName + ' -scheme ' + schemeName + ' -archivePath ' + archiveName
os.system(archive_cmd)

# export
export_cmd = 'xcodebuild -exportArchive -archivePath ' + archiveName + ' -exportPath ' + ipaName + ' -exportFormat ipa -exportProvisioningProfile ' + provisionName
os.system(export_cmd)
