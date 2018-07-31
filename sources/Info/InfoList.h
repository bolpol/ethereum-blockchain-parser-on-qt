#pragma once

#include <QString> // ?
#include <QDir>
#include <QFile>
#include <QList>

class InfoList
{
public:
    InfoList(const int, const QString &);

    int id() const;

    QString info() const;

private:
    int aId;

    QString aInfo;
};
