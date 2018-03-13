import qbs

CppApplication {
    property string toolFileTag
    type: toolFileTag ? base.concat(toolFileTag) : base
    consoleApplication: true
    cpp.defines: ["QT_USE_QSTRINGBUILDER"]
    cpp.discardUnusedData: true

    // ### Remove, when QBS-1310 is fixed.
    qbsSearchPaths: [project.qtbaseShadowDir + "/src/corelib/qbs"]
    Depends { name: "QtCoreConfig" }
    // ### You can stop the removal right here.

    Depends { name: "QtGlobalConfig" }

    property bool useBootstrapLib: QtGlobalConfig.cross_compile
    Properties {
        condition: QtGlobalConfig.release_tools
        qbs.buildVariant: "release"
    }
    qbs.buildVariant: original

    multiplexByQbsProperties: ["profiles"]
    property string hostProfile: "qt_hostProfile"
    qbs.profiles: [hostProfile]

    Depends { name: "Qt.bootstrap-private"; condition: useBootstrapLib }
    Depends { name: "Qt.core"; condition: !useBootstrapLib }
    Depends { name: "osversions" }

    Properties {
        condition: qbs.toolchain.contains("gcc") && QtGlobalConfig.rpath && !useBootstrapLib
        cpp.rpaths: cpp.rpathOrigin + "/../lib"
    }

    cpp.cxxLanguageVersion: "c++11"

    Group {
        fileTagsFilter: "application"
        fileTags: toolFileTag ? [toolFileTag] : undefined
        qbs.install: true
        qbs.installDir: "bin"
    }
}