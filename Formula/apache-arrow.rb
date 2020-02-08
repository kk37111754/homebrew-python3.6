class ApacheArrow < Formula
  desc "Columnar in-memory analytics layer designed to accelerate big data"
  homepage "https://arrow.apache.org/"
  url "https://archive.apache.org/dist/arrow/arrow-0.16.0/apache-arrow-0.16.0.tar.gz"
  mirror "https://www-eu.apache.org/dist/arrow/arrow-0.16.0/apache-arrow-0.16.0.tar.gz"
  sha256 "261992de4029a1593195ff4000501503bd403146471b3168bd2cc414ad0fb7f5"

  patch do
    url "https://github.com/apache/arrow/commit/7e24a84d.patch"
    sha256 "50cf74f10543a5eea667af34de010e1040d6209d8efcf4d4586510961ac08912"
  end

  bottle do
    cellar :any
    sha256 "6127d77c15ca02786364fe0fef5b3fb63dcfc83afdd6a0af18cb20097f6baaca" => :el_capitan_or_later
    root_url "https://autobrew.github.io/bottles"
  end

  depends_on "cmake" => :build
  depends_on "flatbuffers" => :build
  depends_on "boost"
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
      -DFLATBUFFERS_HOME=#{Formula["flatbuffers"].prefix}
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
