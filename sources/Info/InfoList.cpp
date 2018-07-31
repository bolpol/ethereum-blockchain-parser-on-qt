#include "InfoList.h"

InfoList::InfoList(const int id, const QString &text)
    :
      aId(id),
      aInfo(text) {}

int InfoList::id() const
{
    return aId;
}

QString InfoList::info() const
{
    return aInfo;
}
