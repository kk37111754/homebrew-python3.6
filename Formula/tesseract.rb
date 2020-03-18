class Tesseract < Formula
  desc "OCR (Optical Character Recognition) engine"
  homepage "https://github.com/tesseract-ocr/"
  url "https://github.com/tesseract-ocr/tesseract/archive/4.1.0.tar.gz"
  sha256 "5c5ed5f1a76888dc57a83704f24ae02f8319849f5c4cf19d254296978a1a1961"
  head "https://github.com/tesseract-ocr/tesseract.git"

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "4efc3b406ca11f3698c48b6cd6208b2d0b517db0e465f88142fd84000fb0b7c8" => :el_capitan_or_later
  end

  option "with-all-languages", "Install recognition data for all languages"
  option "with-training-tools", "Install OCR training tools"
  option "with-serial-num-pack", "Install serial number recognition pack"

  deprecated_option "all-languages" => "with-all-languages"

  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  depends_on "leptonica"
  depends_on "libtiff"

  if build.with? "training-tools"
    depends_on "libtool" => :build
    depends_on "icu4c"
    depends_on "glib"
    depends_on "cairo"
    depends_on "pango"
    depends_on :x11
  end

  resource "tessdata" do
    url "https://github.com/tesseract-ocr/tessdata_fast/archive/4.0.0.tar.gz"
    sha256 "cfae2d9e15887a719c995baad70c01ad8f68c0361f5f0a4f46e4aa9ed8a47120"
  end

  resource "eng" do
    url "https://github.com/tesseract-ocr/tessdata_fast/raw/4.0.0/eng.traineddata"
    sha256 "7d4322bd2a7749724879683fc3912cb542f19906c83bcc1a52132556427170b2"
  end

  resource "osd" do
    url "https://github.com/tesseract-ocr/tessdata_fast/raw/4.0.0/osd.traineddata"
    sha256 "9cf5d576fcc47564f11265841e5ca839001e7e6f38ff7f7aacf46d15a96b00ff"
  end

  resource "snum" do
    url "https://github.com/USCDataScience/counterfeit-electronics-tesseract/raw/319a6eeacff181dad5c02f3e7a3aff804eaadeca/Training%20Tesseract/snum.traineddata"
    sha256 "36f772980ff17c66a767f584a0d80bf2302a1afa585c01a226c1863afcea1392"
  end


  def install
    if build.with? "training-tools"
      icu4c = Formula["icu4c"]
      ENV.append "CFLAGS", "-I#{icu4c.opt_include}"
      ENV.append "LDFLAGS", "-L#{icu4c.opt_lib}"
    end

    # explicitly state leptonica header location, as the makefile defaults to /usr/local/include,
    # which doesn't work for non-default homebrew location
    ENV["LIBLEPT_HEADERSDIR"] = HOMEBREW_PREFIX/"include"

    ENV.cxx11

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"

    system "make", "install"
    if build.with? "serial-num-pack"
      resource("snum").stage { mv "snum.traineddata", share/"tessdata" }
    end
    if build.with? "training-tools"
      system "make", "training"
      system "make", "training-install"
    end
    if build.with? "all-languages"
      resource("tessdata").stage { mv Dir["*"], share/"tessdata" }
    else
      resource("eng").stage { mv "eng.traineddata", share/"tessdata" }
      resource("osd").stage { mv "osd.traineddata", share/"tessdata" }
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tesseract -v 2>&1")
  end
end
