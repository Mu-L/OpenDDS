/*
* Distributed under the OpenDDS License.
* See: http://www.opendds.org/license.html
*/

#ifndef OPENDDS_DCPS_FLEXIBLETYPESUPPORT_H
#define OPENDDS_DCPS_FLEXIBLETYPESUPPORT_H

#include "dcps_export.h"

#include "TypeSupportImpl.h"

#ifndef ACE_LACKS_PRAGMA_ONCE
#  pragma once
#endif

OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL

namespace OpenDDS {
namespace DCPS {

class OpenDDS_Dcps_Export FlexibleTypeSupport : public TypeSupportImpl {
public:
  FlexibleTypeSupport(TypeSupport& baseTypeSupport,
                      const String& name)
    : base_(dynamic_rchandle_cast<TypeSupportImpl>(
        RcHandle<TypeSupport>(&baseTypeSupport, inc_count())))
    , name_(name)
  {}

  const char* name() const { return name_.c_str(); }
  char* get_type_name();

  DDS::ReturnCode_t add(const String& typeKey,
                        const XTypes::TypeIdentifier& minimalTypeIdentifier,
                        const XTypes::TypeMap& minimalTypeMap,
                        const XTypes::TypeIdentifier& completeTypeIdentifier,
                        const XTypes::TypeMap& completeTypeMap);

  void to_type_info(TypeInformation& type_info) const;
  const XTypes::TypeIdentifier& getMinimalTypeIdentifier() const;
  const XTypes::TypeMap& getMinimalTypeMap() const;
  const XTypes::TypeIdentifier& getCompleteTypeIdentifier() const;
  const XTypes::TypeMap& getCompleteTypeMap() const;

  // the following functions simply delegate to base_
  DDS::DataWriter* create_datawriter() { return base_->create_datawriter(); }
  DDS::DataReader* create_datareader() { return base_->create_datareader(); }
#ifndef OPENDDS_NO_MULTI_TOPIC
  DDS::DataReader* create_multitopic_datareader() { return base_->create_multitopic_datareader(); }
#endif
  void representations_allowed_by_type(DDS::DataRepresentationIdSeq& seq) { base_->representations_allowed_by_type(seq); }
#ifndef OPENDDS_NO_CONTENT_SUBSCRIPTION_PROFILE
  const MetaStruct& getMetaStructForType() { return base_->getMetaStructForType(); }
#endif
  Extensibility getExtensibility() const { return base_->getExtensibility(); }
  const char* default_type_name() const { return base_->default_type_name(); }
  bool has_dcps_key() { return base_->has_dcps_key(); }

private:
  void get_flexible_types(const char* key, XTypes::TypeInformation& type_info);

  RcHandle<TypeSupportImpl> base_;
  String name_;

  struct Alternative {
    Alternative() {}
    Alternative(const XTypes::TypeIdentifier& minimalTypeIdentifier,
                const XTypes::TypeMap& minimalTypeMap,
                const XTypes::TypeIdentifier& completeTypeIdentifier,
                const XTypes::TypeMap& completeTypeMap);
    XTypes::TypeIdentifier minimalId_, completeId_;
    XTypes::TypeMap minimalMap_, completeMap_;
  };
  OPENDDS_MAP(String, Alternative) map_;

  OPENDDS_DELETED_COPY_MOVE_CTOR_ASSIGN(FlexibleTypeSupport)
};

}
}

OPENDDS_END_VERSIONED_NAMESPACE_DECL

#endif
