#pragma once

#include <QObject>
#include <QVariantList>

class Parser : public QObject
{
    Q_OBJECT

public:
    Parser();

    Q_INVOKABLE void setNewInfo(const QString &);

    Q_INVOKABLE void writeAccounts(const QVariantList &);

    Q_INVOKABLE void writeAccountsWithBlock(const QVariantList &, const int);

    Q_INVOKABLE void updateLogs(const int);

private:
    void parseBlocks();

signals:
    Q_INVOKABLE void newInfo(const QString &info);

    Q_INVOKABLE void logsStatus(const int index);
};
