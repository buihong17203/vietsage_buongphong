#!/bin/bash
set -e

echo "=== Đang chuẩn bị môi trường build iOS cho VietSage Buồng phòng ==="
flutter pub get
flutter analyze

echo "=== Đang build bản phát hành iOS (Release) ==="
flutter build ios --release --no-codesign

echo "=== Đang đóng gói file IPA ==="
cd build/ios/iphoneos
rm -rf Payload VietSage_Buong_Phong.ipa
mkdir Payload
cp -r Runner.app Payload/
zip -r "VietSage_Buong_Phong.ipa" Payload

mkdir -p ../../../output_ios
mv VietSage_Buong_Phong.ipa ../../../output_ios/

echo "=========================================================="
echo "SUCCESS: Đã tạo file IPA thành công tại output_ios/VietSage_Buong_Phong.ipa"
echo "=========================================================="
