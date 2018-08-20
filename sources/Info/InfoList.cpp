// Copyright (c) 2018 Pironmind inc.
// This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
// warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
// permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
// License 2.0 that can be found in the LICENSE file.

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
