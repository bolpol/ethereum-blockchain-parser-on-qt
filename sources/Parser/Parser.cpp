#include "Parser.h"
#include <QFile>
#include <QDebug>
#include <QJsonValue>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QStandardPaths>
#include <algorithm>

template <typename T>
void remove_duplicates(std::vector<T>& vec)
{
  std::sort(vec.begin(), vec.end());
  vec.erase(std::unique(vec.begin(), vec.end()), vec.end());
}

Parser::Parser() {}

void Parser::setNewInfo(const QString &text)
{
    emit newInfo(text);
}

void Parser::updateLogs(const int index)
{
    emit logsStatus(index);
}

void Parser::writeAccounts(const QVariantList &data)
{
    QFile file(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + "/parser/accounts.json");

    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QString val = file.readAll();
    file.close();
    QJsonDocument jsonDocumentLastData = QJsonDocument::fromJson(val.toUtf8());
    QJsonArray jsonArray;
    std::vector<QString> allAdresses;

    foreach (const auto &v, data) {
        allAdresses.push_back(v.toString());
    }

    foreach (const auto &v, jsonDocumentLastData.array()) {
        allAdresses.push_back(v.toString());
    }

    remove_duplicates(allAdresses);

    foreach (const auto &v, allAdresses) {
        jsonArray.append(v);
    }

    QJsonDocument jsonDocument(jsonArray);

    if (file.open(QIODevice::WriteOnly))
    {
        file.write(jsonDocument.toJson());
    }

    file.close();
}

void Parser::writeAccountsWithBlock(const QVariantList &data, const int blockId)
{
    QFile file(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + QString("/parser/%1.json").arg(blockId));

    if (!file.exists())
    {
        file.open(QIODevice::WriteOnly);
        file.close();
    }

    QJsonArray jsonArray;

    foreach (const auto &v, data) {
        jsonArray.append(v.toString());
    }

    QJsonDocument jsonDocument(jsonArray);

    if (file.open(QIODevice::WriteOnly))
    {
        file.write(jsonDocument.toJson());
    }

    file.close();
}
