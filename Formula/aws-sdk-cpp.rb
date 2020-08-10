class AwsSdkCpp < Formula
  desc "AWS SDK for C++"
  homepage "https://github.com/aws/aws-sdk-cpp"
  url "https://github.com/aws/aws-sdk-cpp/archive/1.7.364.tar.gz"
  sha256 "05ed242a601b614eb46e8e32b56367fc3f195ff3b63337eb928a72f4776ee495"
  head "https://github.com/aws/aws-sdk-cpp.git"

  bottle do
    rebuild 1
    cellar :any_skip_relocation
    sha256 "d54370c22f5492da270249aa84cbff84dcc25e8c739acb2ac83e69c66436c487" => :high_sierra
    sha256 "37eb362a6190e867daf1b8c9768c9cfbb9d6288675a12cf1142b62f49ffec8c5" => :el_capitan
    root_url "https://autobrew.github.io/bottles"
  end

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", "-DBUILD_SHARED_LIBS=OFF", "-DBUILD_ONLY=config;s3;transfer", "-DENABLE_UNITY_BUILD=ON",  *std_cmake_args
      system "make"
      system "make", "install"
    end

    lib.install Dir[lib/"mac/Release/*"].select { |f| File.file? f }
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <aws/core/Version.h>
      #include <iostream>

      int main() {
          std::cout << Aws::Version::GetVersionString() << std::endl;
          return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-L#{lib}", "-laws-cpp-sdk-core", "-lcurl",
           "-o", "test"
    system "./test"
  end
end
