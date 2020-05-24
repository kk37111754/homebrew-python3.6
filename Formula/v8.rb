class V8 < Formula
  desc "Google's JavaScript engine"
  homepage "https://github.com/v8/v8/wiki"
  # Track V8 version from Chrome stable: https://omahaproxy.appspot.com
  url "https://github.com/v8/v8/archive/8.3.110.9.tar.gz"
  sha256 "ca578e0cccecaa9ec22056ab08a6136adade01730742d0118b4689a2444be43b"

  depends_on "llvm" => :build
  depends_on "ninja" => :build
  depends_on :xcode => ["10.0", :build] # required by v8

  # Jeroen: bottle was actually built on high_sierra using upstream homebrew (with llvm 10)
  # Also added a patch for zlib below to avoid SIMD dependencies.
  bottle do
    cellar :any_skip_relocation
    root_url "https://autobrew.github.io/bottles"
    sha256 "ac576b6f2532698549a5efee87438cd0b05d74dbb5e23ca70a1ba5f77fa1468a" => :high_sierra
    sha256 "ac576b6f2532698549a5efee87438cd0b05d74dbb5e23ca70a1ba5f77fa1468a" => :el_capitan
  end

  # Look up the correct resource revisions in the DEP file of the specific releases tag
  # e.g. for CIPD dependency gn: https://github.com/v8/v8/blob/7.6.303.27/DEPS#L15
  resource "gn" do
    url "https://gn.googlesource.com/gn.git",
      :revision => "5ed3c9cc67b090d5e311e4bd2aba072173e82db9"
  end

  # e.g.: https://github.com/v8/v8/blob/7.6.303.27/DEPS#L60 for the revision of build for v8 7.6.303.27
  resource "v8/build" do
    url "https://chromium.googlesource.com/chromium/src/build.git",
      :revision => "26e9d485d01d6e0eb9dadd21df767a63494c8fea"

    # revert usage of unsuported libtool option -D (fixes High Sierra support)
    patch do
      url "https://github.com/denoland/chromium_build/commit/56551e71dc0281cc1d9471caf6a02d02f18c830e.patch?full_index=1"
      sha256 "46fea09483c8b5699f47ae5886d933b61bed11bb3cda88212a7467767db0be3c"
    end
  end

  resource "v8/base/trace_event/common" do
    url "https://chromium.googlesource.com/chromium/src/base/trace_event/common.git",
      :revision => "dab187b372fc17e51f5b9fad8201813d0aed5129"
  end

  resource "v8/third_party/googletest/src" do
    url "https://chromium.googlesource.com/external/github.com/google/googletest.git",
      :revision => "10b1902d893ea8cc43c69541d70868f91af3646b"
  end

  resource "v8/third_party/jinja2" do
    url "https://chromium.googlesource.com/chromium/src/third_party/jinja2.git",
      :revision => "b41863e42637544c2941b574c7877d3e1f663e25"
  end

  resource "v8/third_party/markupsafe" do
    url "https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git",
      :revision => "8f45f5cfa0009d2a70589bcda0349b8cb2b72783"
  end

  resource "v8/third_party/zlib" do
    url "https://chromium.googlesource.com/chromium/src/third_party/zlib.git",
      :revision => "156be8c52f80cde343088b4a69a80579101b6e67"

    # disable simd extensions which are broken for static linking
    patch :p3 do
      url "https://github.com/chromium/chromium/pull/54.patch"
      sha256 "7770ff790f35c0ed625b0e8d761f327cb6c635a0b160f588e517c43ff4d59483"
    end
  end

  def install
    (buildpath/"build").install resource("v8/build")
    (buildpath/"third_party/jinja2").install resource("v8/third_party/jinja2")
    (buildpath/"third_party/markupsafe").install resource("v8/third_party/markupsafe")
    (buildpath/"third_party/googletest/src").install resource("v8/third_party/googletest/src")
    (buildpath/"base/trace_event/common").install resource("v8/base/trace_event/common")
    (buildpath/"third_party/zlib").install resource("v8/third_party/zlib")

    # Build gn from source and add it to the PATH
    (buildpath/"gn").install resource("gn")
    cd "gn" do
      system "python", "build/gen.py"
      system "ninja", "-C", "out/", "gn"
    end
    ENV.prepend_path "PATH", buildpath/"gn/out"

    # Enter the v8 checkout
    gn_args = {
      :v8_static_library => true,
      :enable_nacl => false,
      :symbol_level => 0,
      :is_debug                     => false,
      :is_component_build           => false,
      :v8_use_external_startup_data => false,
      :v8_enable_i18n_support       => false, # enables i18n support with icu
      :clang_base_path              => "\"#{Formula["llvm"].prefix}\"",
      :clang_use_chrome_plugins     => false, # disable the usage of Google's custom clang plugins
      :use_custom_libcxx            => false, # uses system libc++ instead of Google's custom one
      :treat_warnings_as_errors     => false,
    }

    # overwrite Chromium minimum sdk version of 10.15
    ENV["FORCE_MAC_SDK_MIN"] = "10.13"
    # link against system libc++ instead of llvm provided libc++
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib

    # Transform to args string
    gn_args_string = gn_args.map { |k, v| "#{k}=#{v}" }.join(" ")

    # Build with gn + ninja
    system "gn", "gen", "--args=#{gn_args_string}", "out.gn"
    system "ninja", "-j", ENV.make_jobs, "-C", "out.gn", "-v", "d8"

    # Install all the things
    (libexec/"include").install Dir["include/*"]
    libexec.install Dir["out.gn/obj/lib*.a", "out.gn/obj/third_party/zlib/libchrome_zlib.a",
      "out.gn/obj/third_party/zlib/google/libcompression_utils_portable.a", "out.gn/d8"]
    bin.write_exec_script libexec/"d8"
  end

  test do
    assert_equal "Hello World!", shell_output("#{bin}/d8 -e 'print(\"Hello World!\");'").chomp
    t = "#{bin}/d8 -e 'print(new Intl.DateTimeFormat(\"en-US\").format(new Date(\"2012-12-20T03:00:00\")));'"
    assert_match %r{12/\d{2}/2012}, shell_output(t).chomp

    (testpath/"test.cpp").write <<~'EOS'
      #include <libplatform/libplatform.h>
      #include <v8.h>
      int main(){
        static std::unique_ptr<v8::Platform> platform = v8::platform::NewDefaultPlatform();
        v8::V8::InitializePlatform(platform.get());
        v8::V8::Initialize();
        return 0;
      }
    EOS

    # link against installed libc++
    system ENV.cxx, "-std=c++11", "test.cpp",
      "-I#{libexec}/include",
      "-L#{libexec}", "-lv8", "-lv8_libplatform"
  end
end
