class CurlNss < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  url "https://curl.se/download/curl-7.76.1.tar.bz2"
  sha256 "7a8e184d7d31312c4ebf6a8cb59cd757e61b2b2833a9ed4f9bf708066e7695e9"
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  bottle do
    root_url "https://github.com/nbrideau/homebrew-curlnss/releases/download/v7.76.1"
    sha256 cellar: :any, big_sur: "7588458470cd4c58eefdc1d3a23e26fb7717be8664498d17da23d556bd917577"
  end
  
  head do
    url "https://github.com/curl/curl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "libidn2"
  depends_on "libmetalink"
  depends_on "libssh2"
  depends_on "nghttp2"
  depends_on "openldap"
  depends_on "rtmpdump"
  depends_on "zstd"
  depends_on "nss"
  depends_on "c-ares"

  uses_from_macos "krb5"
  uses_from_macos "zlib"

  def install
    system "./buildconf" if build.head?

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-ssl
      --with-nss
      --with-ares
      --with-gssapi
      --with-libidn2
      --with-libmetalink
      --with-librtmp
      --with-libssh2
      --without-libpsl
    ]

    on_macos do
      args << "--with-gssapi"
    end

    on_linux do
      args << "--with-gssapi=#{Formula["krb5"].opt_prefix}"
    end

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "lib/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
