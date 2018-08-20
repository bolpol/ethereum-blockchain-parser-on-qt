// Copyright (c) 2018 Pironmind inc.
// This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
// warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
// permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
// License 2.0 that can be found in the LICENSE file.

#include "InfoModel.h"
#include <QDebug>

InfoModel::InfoModel(QObject *parent)
    :
      QAbstractListModel(parent) {}

void InfoModel::addInfo(const InfoList &info)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());

    mInfo << info;

    endInsertRows();
}

int InfoModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    return mInfo.count();
}

QVariant InfoModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= mInfo.count())
        return QVariant();

    const InfoList &info = mInfo[index.row()];

    if (role == IdRole)
        return info.id();
    else if(role == InfoRole)
        return info.info();

    return QVariant();
}

QVariant InfoModel::get(const int &index, const int &role) const
{
    if (index < 0 || index >= mInfo.count())
        return QVariant();

    const InfoList &info = mInfo[index];

    if (0 == info.id())
        return QVariant();

    if (role == IdRole)
        return info.id();
    else if(role == InfoRole)
        return info.info();

    return QVariant();
}

QHash<int, QByteArray> InfoModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[IdRole] = "id";
    roles[InfoRole] = "info";

    return roles;
}

void InfoModel::newInfo(const QString &text)
{
    int id = mInfo.count();

    addInfo(InfoList(++id, text));
}
