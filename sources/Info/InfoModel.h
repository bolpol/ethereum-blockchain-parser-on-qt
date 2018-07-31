#pragma once

#include <QAbstractListModel>
#include <QStringList>
#include <QModelIndex>
#include "InfoList.h"

class InfoModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum InfoRoles {
        IdRole = Qt::UserRole + 1,
        InfoRole,
    };

    InfoModel(QObject *parent = 0);

    void addInfo(const InfoList &);

    int rowCount(const QModelIndex & = QModelIndex()) const;

    QVariant data(const QModelIndex &, int role = Qt::DisplayRole) const;

    Q_INVOKABLE QVariant get(const int &, const int &) const;

    Q_INVOKABLE void newInfo(const QString &);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<InfoList> mInfo;
};
