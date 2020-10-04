class ImagemagickAT6 < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://dl.bintray.com/homebrew/mirror/imagemagick%406-6.9.11-32.tar.xz"
  mirror "https://www.imagemagick.org/download/releases/ImageMagick-6.9.11-32.tar.xz"
  sha256 "151733e004cb1b49c77e04e1257b9883b6cce2221fc44b0176845e14f75eca52"
  head "https://github.com/imagemagick/imagemagick6.git"

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "fdf2bda541cd8d20f06864c859c8cc960938d0f92a14f59d0b0bcfa5c559578d" => :el_capitan
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on "gettext" => :test # via cairo
  depends_on "libtool"
  depends_on "xz"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "freetype"
  depends_on "fontconfig"
  depends_on "librsvg"
  depends_on "openjpeg"
  depends_on "pango"
  depends_on "webp"

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-shared
      --enable-static
      --with-freetype
      --with-fontconfig
      --with-openjp2
      --with-webp
      --with-pango
      --with-rsvg
      --without-x
      --without-wmf
      --without-modules
      --without-gslib
      --without-openmp
      --without-fftw
      --without-perl
      --enable-zero-configuration
      --with-gs-font-dir=/usr/local/share/ghostscript/fonts
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[fontconfig pango cairo rsvg webp freetype jpeg jp2 png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
