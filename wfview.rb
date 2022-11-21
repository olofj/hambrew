class Wfview < Formula
  desc "Open Source interface for Icom transceivers"
  homepage "https://wfview.org/"
  url "https://gitlab.com/eliggett/wfview/-/archive/v1.50/wfview-v1.50.tar.gz"
  sha256 "c1c0835c678b70d8675e1e21d5c26263efbed7b117912ba81d60a6c301e2786c"
  license "GPL-3.0-only"

  depends_on "eigen"
  depends_on "opus"
  depends_on "portaudio"
  depends_on "pulseaudio"
  depends_on "qcustomplot"
  depends_on "qt@5"
  depends_on "rtaudio"

  patch :DATA

  def install
    # I don't know why I need to manually add the -I and -L args here, but.. I do?
    ENV.append "CXXFLAGS", "-I#{Formula["opus"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["eigen"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["portaudio"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["qcustomplot"].opt_include}/qcustomplot"
    ENV.append "CXXFLAGS", "-I#{Formula["rtaudio"].opt_include}/rtaudio"
    ENV.append "LDFLAGS", "-L#{Formula["opus"].opt_lib}"
    ENV.append "LDFLAGS", "-L#{Formula["portaudio"].opt_lib}"
    ENV.append "LDFLAGS", "-L#{Formula["qcustomplot"].opt_lib}"
    ENV.append "LDFLAGS", "-L#{Formula["rtaudio"].opt_lib}"
    ENV.append "LDFLAGS", "-L#{Formula["pulseaudio"].opt_lib}"
    qt5 = Formula["qt@5"].opt_prefix
    system "#{qt5}/bin/qmake",
      "CONFIG+=c++17",
      "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
      "QMAKE_CXXFLAGS=#{ENV.cxxflags}",
      "QMAKE_LIBS=#{ENV.ldflags}",
      "wfview.pro"
    system "make"
    prefix.install "wfview.app"
    bin.write_exec_script "#{prefix}/wfview.app/Contents/MacOS/wfview"
  end

  test do
    # There isn't much we can do to test it from the command line, but
    # we can at least make sure it can display its version.
    system "#{bin}/wfview", "-v"
  end
end

__END__
diff --git a/wfview.pro b/wfview.pro
index ce40277..8cd16d1 100644
--- a/wfview.pro
+++ b/wfview.pro
@@ -41,11 +41,12 @@ win32:DEFINES += __WINDOWS_WASAPI__
 #linux:DEFINES += __LINUX_OSS__
 linux:DEFINES += __LINUX_PULSE__
 macx:DEFINES += __MACOSX_CORE__
-!linux:SOURCES += ../rtaudio/RTAudio.cpp
-!linux:HEADERS += ../rtaudio/RTAUdio.h
-!linux:INCLUDEPATH += ../rtaudio
+win32:SOURCES += ../rtaudio/RTAudio.cpp
+win32:HEADERS += ../rtaudio/RTAUdio.h
+win32:INCLUDEPATH += ../rtaudio
 
 linux:LIBS += -lpulse -lpulse-simple -lrtaudio -lpthread
+macx:LIBS += -lpulse -lpulse-simple -lrtaudio -lpthread
 
 win32:INCLUDEPATH += ../portaudio/include
 !win32:LIBS += -lportaudio
@@ -80,17 +81,13 @@ isEmpty(PREFIX) {
 
 DEFINES += PREFIX=\\\"$$PREFIX\\\"
 
-macx:INCLUDEPATH += /usr/local/include /opt/local/include 
-macx:LIBS += -L/usr/local/lib -L/opt/local/lib
-
-macx:ICON = ../wfview/resources/wfview.icns
+macx:ICON = wfview/resources/wfview.icns
 win32:RC_ICONS = ../wfview/resources/wfview.ico
-QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.13
 QMAKE_TARGET_BUNDLE_PREFIX = org.wfview
 MY_ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
-MY_ENTITLEMENTS.value = ../wfview/resources/wfview.entitlements
+MY_ENTITLEMENTS.value = wfview/resources/wfview.entitlements
 QMAKE_MAC_XCODE_SETTINGS += MY_ENTITLEMENTS
-QMAKE_INFO_PLIST = ../wfview/resources/Info.plist
+QMAKE_INFO_PLIST = wfview/resources/Info.plist
 
 !win32:DEFINES += HOST=\\\"`hostname`\\\" UNAME=\\\"`whoami`\\\"
 
@@ -136,13 +133,13 @@ CONFIG(debug, release|debug) {
 }
 
 linux:LIBS += -L./ -l$$QCPLIB -lopus
-macx:LIBS += -framework CoreAudio -framework CoreFoundation -lpthread -lopus 
+macx:LIBS += -framework CoreAudio -framework CoreFoundation -lqcustomplot -lopus -lpthread 
 
-!linux:SOURCES += ../qcustomplot/qcustomplot.cpp 
-!linux:HEADERS += ../qcustomplot/qcustomplot.h
-!linux:INCLUDEPATH += ../qcustomplot
+win32:SOURCES += ../qcustomplot/qcustomplot.cpp 
+win32:HEADERS += ../qcustomplot/qcustomplot.h
+win32:INCLUDEPATH += ../qcustomplot
 
-!linux:INCLUDEPATH += ../opus/include
+win32:INCLUDEPATH += ../opus/include
 
 win32:INCLUDEPATH += ../eigen
 win32:INCLUDEPATH += ../r8brain-free-src
