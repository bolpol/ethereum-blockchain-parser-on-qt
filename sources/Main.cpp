// Copyright (c) 2018 Pironmind inc.
// This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
// warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
// permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
// License 2.0 that can be found in the LICENSE file.

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include "sources/Info/InfoModel.h"
#include "sources/Parser/Parser.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    auto mainDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + "/parser";

    if (!QDir(mainDir).exists())
        QDir().mkdir(mainDir);

    Parser parser;

    qmlRegisterType<InfoModel>("InfoModel", 1, 0, "InfoModel");
    qRegisterMetaType<InfoModel*>("InfoModel");

    engine.rootContext()->setContextProperty("ParserService", &parser);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
