class X264 < Formula
  desc "H.264/AVC encoder"
  homepage "https://www.videolan.org/developers/x264.html"
  head "https://git.videolan.org/git/x264.git"

  stable do
    # the latest commit on the stable branch
    url "https://git.videolan.org/git/x264.git",
        :revision => "0a84d986e7020f8344f00752e3600b9769cc1e85"
    version "r2917"
  end

  bottle do
    cellar :any
    root_url "https://autobrew.github.io/bottles"
    sha256 "b848b6282558496b4ca4f39c8358f6f600cca2bb09da3e1af326d058b3fe989d" => :el_capitan
  end

  depends_on "nasm" => :build

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-lsmash
      --enable-shared
      --enable-static
      --enable-strip
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdint.h>
      #include <x264.h>

      int main()
      {
          x264_picture_t pic;
          x264_picture_init(&pic);
          x264_picture_alloc(&pic, 1, 1, 1);
          x264_picture_clean(&pic);
          return 0;
      }
    EOS
    system ENV.cc, "-L#{lib}", "-lx264", "test.c", "-o", "test"
    system "./test"
  end
end
