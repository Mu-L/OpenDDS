/*
 *
 *
 * Distributed under the OpenDDS License.
 * See: http://www.opendds.org/license.html
 */

#ifndef OPENDDS_DCPS_TYPESUPPORTIMPL_H
#define OPENDDS_DCPS_TYPESUPPORTIMPL_H

#include "dcps_export.h"
#include "Definitions.h"
#include "Discovery.h"
#include "LocalObject.h"
#include "Serializer.h"
#include "SafetyProfileStreams.h"

#include "XTypes/TypeObject.h"

#include <dds/DdsDcpsTypeSupportExtC.h>

#if !defined (ACE_LACKS_PRAGMA_ONCE)
#pragma once
#endif /* ACE_LACKS_PRAGMA_ONCE */

OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL

namespace OpenDDS {
  namespace XTypes {
    class TypeLookupService;
    typedef DCPS::RcHandle<TypeLookupService> TypeLookupService_rch;
  }

namespace DCPS {

class MetaStruct;
struct TypeInformation;

template <typename Message> struct DDSTraits;

template <typename Message> struct MarshalTraits;

class OpenDDS_Dcps_Export SerializedSizeBound {
public:
  SerializedSizeBound()
  : bounded_(false)
  , bound_(0)
  {
  }

  SerializedSizeBound(size_t bound)
  : bounded_(true)
  , bound_(bound)
  {
  }

  operator bool() const
  {
    return bounded_;
  }

  size_t get() const
  {
    OPENDDS_ASSERT(bounded_);
    return bound_;
  }

  OPENDDS_STRING to_string() const
  {
    return bounded_ ? to_dds_string(bound_) : "<unbounded>";
  }

private:
  bool bounded_;
  size_t bound_;
};

class OpenDDS_Dcps_Export TypeSupportImpl
  : public virtual LocalObject<TypeSupport> {
public:
  TypeSupportImpl() {}

  virtual ~TypeSupportImpl();

#ifndef OPENDDS_NO_CONTENT_SUBSCRIPTION_PROFILE
  virtual const MetaStruct& getMetaStructForType() = 0;
#endif

  virtual DDS::ReturnCode_t register_type(DDS::DomainParticipant_ptr participant,
                                          const char* type_name);

  virtual DDS::ReturnCode_t unregister_type(DDS::DomainParticipant_ptr participant,
                                            const char* type_name);

  virtual char* get_type_name();

  /// Get allowed representations defined by IDL annotations
  virtual void representations_allowed_by_type(
    DDS::DataRepresentationIdSeq& seq) = 0;

  virtual const XTypes::TypeIdentifier& getMinimalTypeIdentifier() const = 0;
  virtual const XTypes::TypeMap& getMinimalTypeMap() const = 0;
  virtual const XTypes::TypeIdentifier& getCompleteTypeIdentifier() const = 0;
  virtual const XTypes::TypeMap& getCompleteTypeMap() const = 0;

  virtual Extensibility getExtensibility() const = 0;
  virtual void to_type_info(TypeInformation& type_info) const;

  virtual void get_flexible_types(const char* /*key*/,
                                  XTypes::TypeInformation& /*type_info*/) {}

  void add_types(const XTypes::TypeLookupService_rch& tls) const;

  RepresentationFormat* make_format(DDS::DataRepresentationId_t representation);

  virtual void populate_dependencies(const RcHandle<XTypes::TypeLookupService>& tls) const;

  static const ACE_CDR::Long TYPE_INFO_DEPENDENT_COUNT_NOT_PROVIDED;

  virtual const char* default_type_name() const = 0;

  void to_type_info_i(XTypes::TypeIdentifierWithDependencies& ti_with_deps,
                      const XTypes::TypeIdentifier& ti,
                      const XTypes::TypeMap& type_map) const;

private:
  void populate_dependencies_i(const XTypes::TypeLookupService_rch& tls,
                               XTypes::EquivalenceKind ek) const;

#ifndef OPENDDS_SAFETY_PROFILE
  XTypes::TypeLookupService_rch type_lookup_service_;
#endif

  OPENDDS_DELETED_COPY_MOVE_CTOR_ASSIGN(TypeSupportImpl)

};

const char* kind_to_string(const XTypes::EquivalenceKind ek);

template<typename Type>
void set_default(Type&)
{
  OPENDDS_ASSERT(false);
}

template<typename Type, typename Tag>
void set_default(IDL::DistinctType<Type, Tag>)
{
  OPENDDS_ASSERT(false);
}

} // namespace DCPS
} // namespace OpenDDS

OPENDDS_END_VERSIONED_NAMESPACE_DECL

#endif
