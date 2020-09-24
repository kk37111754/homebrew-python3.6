class Opencv < Formula
  desc "Open source computer vision library"
  homepage "https://opencv.org/"
  url "https://github.com/opencv/opencv/archive/4.4.0.tar.gz"
  sha256 "bb95acd849e458be7f7024d17968568d1ccd2f0681d47fd60d34ffb4b8c52563"

  bottle do
    cellar :any_skip_relocation
    root_url "https://autobrew.github.io/bottles"
    sha256 "d0b2cc3827d93acb8623aaffc0d892329caf6ecd354daa328d5c657dd83b5d6a" => :el_capitan
    sha256 "06caa7636ee22caaf325d756883dfb94668439ec3da49d02df673eac7d73204a" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "eigen"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "webp"
  depends_on "python" => :build
  depends_on "tbb"

  resource "contrib" do
    url "https://github.com/opencv/opencv_contrib/archive/4.4.0.tar.gz"
    sha256 "a69772f553b32427e09ffbfd0c8d5e5e47f7dab8b3ffc02851ffd7f912b76840"
  end

  def install
    ENV.cxx11
    resource("contrib").stage buildpath/"opencv_contrib"

    # Avoid Accelerate.framework
    ENV["OpenBLAS_HOME"] = Formula["openblas"].opt_prefix
    ENV.delete("PYTHONPATH")

    args = std_cmake_args + %W[
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DBUILD_EXAMPLES=OFF
      -DBUILD_opencv_apps=OFF
      -DBUILD_JASPER=OFF
      -DBUILD_ZLIB=OFF
      -DBUILD_JPEG=OFF
      -DBUILD_WEBP=OFF
      -DBUILD_OPENEXR=OFF
      -DBUILD_PERF_TESTS=OFF
      -DBUILD_PNG=OFF
      -DBUILD_TESTS=OFF
      -DBUILD_TIFF=OFF
      -DBUILD_opencv_hdf=OFF
      -DBUILD_opencv_java=OFF
      -DBUILD_opencv_text=OFF
      -DOPENCV_ENABLE_NONFREE=ON
      -DOPENCV_EXTRA_MODULES_PATH=#{buildpath}/opencv_contrib/modules
      -DOPENCV_GENERATE_PKGCONFIG=ON
      -DWITH_ITT=OFF
      -DWITH_XINE=OFF
      -DWITH_1394=OFF
      -DWITH_CUDA=OFF
      -DWITH_EIGEN=ON
      -DWITH_FFMPEG=OFF
      -DWITH_GPHOTO2=OFF
      -DWITH_GSTREAMER=OFF
      -DWITH_JASPER=OFF
      -DWITH_OPENEXR=OFF
      -DWITH_OPENGL=OFF
      -DWITH_QT=OFF
      -DWITH_TBB=ON
      -DWITH_VTK=OFF
      -DWITH_PROTOBUF=OFF
      -DWITH_QUIRC=OFF
      -DWITH_ADE=OFF
      -DWITH_IPP=OFF
      -DBUILD_opencv_python2=OFF
      -DBUILD_opencv_python3=OFF
    ]

    if build.bottle?
      args += %w[-DENABLE_SSE41=OFF -DENABLE_SSE42=OFF -DENABLE_AVX=OFF
                 -DENABLE_AVX2=OFF]
    end

    mkdir "build" do
      system "cmake", "..", "-DBUILD_SHARED_LIBS=OFF", *args
      inreplace "modules/core/version_string.inc", "#{HOMEBREW_SHIMS_PATH}/mac/super/", ""
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <opencv2/opencv.hpp>
      #include <iostream>
      int main() {
        std::cout << CV_VERSION << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-I#{include}/opencv4",
                    "-o", "test"
    assert_equal `./test`.strip, version.to_s
  end
end
