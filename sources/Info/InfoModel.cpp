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
