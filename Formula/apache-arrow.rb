class ApacheArrow < Formula
  desc "Columnar in-memory analytics layer designed to accelerate big data"
  homepage "https://arrow.apache.org/"
  url "https://downloads.apache.org/arrow/arrow-0.17.1/apache-arrow-0.17.1.tar.gz"
  # Uncomment and update to test on a release candidate
  # url "https://dist.apache.org/repos/dist/dev/arrow/apache-arrow-0.17.1-rc1/apache-arrow-0.17.1.tar.gz"
  sha256 "cbc51c343bca08b10f7f1b2ef15cb15057c30e5e9017cfcee18337b7e2da9ea2"

  bottle do
    cellar :any
    sha256 "e31e367003c68535202852069626a9868de5338820e8b48fda3ad42058185add" => :el_capitan
    root_url "https://autobrew.github.io/bottles"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "lz4"
  depends_on "thrift"
  depends_on "snappy"

  def install
    ENV.cxx11
    args = %W[
      -DARROW_COMPUTE=ON
      -DARROW_CSV=ON
      -DARROW_DATASET=ON
      -DARROW_FILESYSTEM=ON
      -DARROW_HDFS=OFF
      -DARROW_JSON=ON
      -DARROW_PARQUET=ON
      -DARROW_BUILD_SHARED=OFF
      -DARROW_JEMALLOC=OFF
      -DARROW_USE_GLOG=OFF
      -DARROW_PYTHON=OFF
      -DARROW_S3=OFF
      -DARROW_WITH_LZ4=ON
      -DARROW_WITH_ZLIB=ON
      -DARROW_WITH_ZSTD=OFF
      -DARROW_WITH_SNAPPY=ON
      -DARROW_BUILD_UTILITIES=ON
      -DPARQUET_BUILD_EXECUTABLES=ON
      -DLZ4_HOME=#{Formula["lz4"].prefix}
      -DTHRIFT_HOME=#{Formula["thrift"].prefix}
    ]

    mkdir "build"
    cd "build" do
      system "cmake", "../cpp", *std_cmake_args, *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "arrow/api.h"
      int main(void) {
        arrow::int64();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}", "-L#{lib}", "-larrow", "-o", "test"
    system "./test"
  end
end
