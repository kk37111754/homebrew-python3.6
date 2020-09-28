class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-4.2.4.tar.xz"
  sha256 "0d5da81feba073ee78e0f18e0966bcaf91464ae75e18e9a0135186249e3d2a0b"
  head "https://github.com/FFmpeg/FFmpeg.git"

  bottle do
    cellar :any_skip_relocation
    root_url "https://autobrew.github.io/bottles"
    sha256 "996f37c818b88711a2e403b0be64422303c2373ce9ab5a4d1b028e60a8d0bb96" => :high_sierra
    sha256 "076b58f0a2f5831bcba02aab7902b435ec1e4f261b6dbc07e9f39bf96877759f" => :el_capitan
  end

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "texi2html" => :build

  depends_on "lame"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "x264"
  depends_on "xvid"

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --enable-hardcoded-tables
      --enable-avresample
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-ffplay
      --enable-gpl
      --enable-libmp3lame
      --enable-libvorbis
      --enable-libvpx
      --enable-libx264
      --enable-libxvid
    ]

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install Dir["tools/*"].select { |f| File.executable? f }

    # Fix for Non-executables that were installed to bin/
    mv bin/"python", pkgshare/"python", force: true
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
