#!/usr/bin/env perl

use strict;
use warnings;

use Config;
use FileHandle;
use File::Spec;

if (!defined $ENV{ACE_ROOT}) {
  print("You must define the ACE_ROOT environment variable.\n");
  exit(1);
}

if (!defined $ENV{DDS_ROOT}) {
  print("You must define the DDS_ROOT environment variable.\n");
  exit(1);
}

my $patchexe = which('patch');
if (!defined $patchexe) {
  print("This script requires the 'patch' program to be in your PATH.\n");
  exit(1);
}

if (chdir($ENV{DDS_ROOT})) {
  ## Generate the files for CMake
  system("$ENV{ACE_ROOT}/bin/mwc.pl -type cmake -features xerces3=1,no_opendds_security=0,no_rapidjson=0,no_opendds_safety_profile=0 dds");
  system("$ENV{ACE_ROOT}/bin/mwc.pl -type cmake -features xerces3=1,no_opendds_security=0,no_rapidjson=0 dds");
  system("$ENV{ACE_ROOT}/bin/mwc.pl -type cmake -features xerces3=1,no_opendds_security=0,no_rapidjson=0 -exclude tests/cmake tests");

  apply_patch();
}
else {
  print("Unable to change directory to $ENV{DDS_ROOT}\n");
  exit(1);
}

sub which {
  my $prog = shift;

  if (defined $ENV{'PATH'}) {
    my $envSep = ($^O eq 'VMS' ? ':' : $Config{'path_sep'});
    foreach my $part (split(/$envSep/, $ENV{'PATH'})) {
      $part .= "/$prog";
      if (-x "$part$Config{'exe_ext'}") {
        return '"' . File::Spec->canonpath($part) . '"';
      }
    }
  }

  return undef;
}

sub apply_patch {
  my $fh = new FileHandle();
  my $file = 'cmake.patch';
  my $patch = '
--- orig/dds/CMakeLists.OpenDDS_Dcps	2022-11-21 14:09:27.000000000 -0600
+++ dds/CMakeLists.OpenDDS_Dcps	2022-11-21 14:30:11.966562700 -0600
@@ -19,11 +19,20 @@
 
 set(SOURCE_FILES_OPENDDS_DCPS DCPS/BitPubListenerImpl.cpp DCPS/BuiltInTopicUtils.cpp DCPS/CoherentChangeControl.cpp DCPS/ConditionImpl.cpp DCPS/ConfigUtils.cpp DCPS/ConnectionRecords.cpp DCPS/ContentFilteredTopicImpl.cpp DCPS/DCPS_Utils.cpp DCPS/DataDurabilityCache.cpp DCPS/DataReaderImpl.cpp DCPS/DataSampleElement.cpp DCPS/DataSampleHeader.cpp DCPS/DataWriterImpl.cpp DCPS/DcpsUpcalls.cpp DCPS/Discovery.cpp DCPS/DisjointSequence.cpp DCPS/DispatchService.cpp DCPS/DomainParticipantFactoryImpl.cpp DCPS/DomainParticipantImpl.cpp DCPS/EntityImpl.cpp DCPS/EventDispatcher.cpp DCPS/FileSystemStorage.cpp DCPS/FilterEvaluator.cpp DCPS/GroupRakeData.cpp DCPS/GuardCondition.cpp DCPS/GuidBuilder.cpp DCPS/GuidConverter.cpp DCPS/GuidUtils.cpp DCPS/Hash.cpp DCPS/InstanceDataSampleList.cpp DCPS/InstanceHandle.cpp DCPS/InstanceState.cpp DCPS/JobQueue.cpp DCPS/LinuxNetworkConfigMonitor.cpp DCPS/LogAddr.cpp DCPS/Logging.cpp DCPS/Marked_Default_Qos.cpp DCPS/MemoryPool.cpp DCPS/MessageTracker.cpp DCPS/MonitorFactory.cpp DCPS/MultiTopicDataReaderBase.cpp DCPS/MultiTopicImpl.cpp DCPS/MulticastManager.cpp DCPS/NetworkAddress.cpp DCPS/NetworkConfigModifier.cpp DCPS/NetworkConfigMonitor.cpp DCPS/NetworkResource.cpp DCPS/Observer.cpp DCPS/OwnershipManager.cpp DCPS/PeriodicEvent.cpp DCPS/PublisherImpl.cpp DCPS/Qos_Helper.cpp DCPS/QueryConditionImpl.cpp DCPS/RawDataSample.cpp DCPS/ReactorInterceptor.cpp DCPS/ReactorTask.cpp DCPS/ReadConditionImpl.cpp DCPS/ReceivedDataElementList.cpp DCPS/ReceivedDataStrategy.cpp DCPS/Recorder.cpp DCPS/RecorderImpl.cpp DCPS/Registered_Data_Types.cpp DCPS/Replayer.cpp DCPS/ReplayerImpl.cpp DCPS/RepoIdBuilder.cpp DCPS/RepoIdConverter.cpp DCPS/RepoIdGenerator.cpp DCPS/SafetyProfilePool.cpp DCPS/SafetyProfileSequences.cpp DCPS/SafetyProfileStreams.cpp DCPS/SendStateDataSampleList.cpp DCPS/SequenceNumber.cpp DCPS/Serializer.cpp DCPS/ServiceEventDispatcher.cpp DCPS/Service_Participant.cpp DCPS/SporadicEvent.cpp DCPS/StaticDiscovery.cpp DCPS/StatusConditionImpl.cpp DCPS/SubscriberImpl.cpp DCPS/SubscriptionInstance.cpp DCPS/ThreadPool.cpp DCPS/ThreadStatusManager.cpp DCPS/TimeDuration.cpp DCPS/Time_Helper.cpp DCPS/TopicDescriptionImpl.cpp DCPS/TopicImpl.cpp DCPS/Transient_Kludge.cpp DCPS/TypeSupportImpl.cpp DCPS/ValueReader.cpp DCPS/ValueWriter.cpp DCPS/WaitSet.cpp DCPS/WriteDataContainer.cpp DCPS/WriterDataSampleList.cpp DCPS/WriterInfo.cpp DCPS/XTypes/DynamicDataImpl.cpp DCPS/XTypes/DynamicTypeImpl.cpp DCPS/XTypes/DynamicTypeMemberImpl.cpp DCPS/XTypes/MemberDescriptorImpl.cpp DCPS/XTypes/TypeAssignability.cpp DCPS/XTypes/TypeDescriptorImpl.cpp DCPS/XTypes/TypeLookupService.cpp DCPS/XTypes/TypeObject.cpp DCPS/debug.cpp DCPS/security/framework/HandleRegistry.cpp DCPS/security/framework/SecurityConfig.cpp DCPS/security/framework/SecurityPluginInst.cpp DCPS/security/framework/SecurityRegistry.cpp DCPS/transport/framework/BuildChainVisitor.cpp DCPS/transport/framework/CopyChainVisitor.cpp DCPS/transport/framework/DataLink.cpp DCPS/transport/framework/DataLinkCleanupTask.cpp DCPS/transport/framework/DataLinkSet.cpp DCPS/transport/framework/DirectPriorityMapper.cpp DCPS/transport/framework/NullSynch.cpp DCPS/transport/framework/NullSynchStrategy.cpp DCPS/transport/framework/PacketRemoveVisitor.cpp DCPS/transport/framework/PerConnectionSynch.cpp DCPS/transport/framework/PerConnectionSynchStrategy.cpp DCPS/transport/framework/PoolSynch.cpp DCPS/transport/framework/PoolSynchStrategy.cpp DCPS/transport/framework/PriorityKey.cpp DCPS/transport/framework/PriorityMapper.cpp DCPS/transport/framework/QueueRemoveVisitor.cpp DCPS/transport/framework/ReactorSynch.cpp DCPS/transport/framework/ReactorSynchStrategy.cpp DCPS/transport/framework/ReceiveListenerSet.cpp DCPS/transport/framework/ReceiveListenerSetMap.cpp DCPS/transport/framework/ReceivedDataSample.cpp DCPS/transport/framework/RemoveAllVisitor.cpp DCPS/transport/framework/ScheduleOutputHandler.cpp DCPS/transport/framework/SendResponseListener.cpp DCPS/transport/framework/ThreadPerConRemoveVisitor.cpp DCPS/transport/framework/ThreadPerConnectionSendTask.cpp DCPS/transport/framework/ThreadSynch.cpp DCPS/transport/framework/ThreadSynchResource.cpp DCPS/transport/framework/ThreadSynchStrategy.cpp DCPS/transport/framework/ThreadSynchWorker.cpp DCPS/transport/framework/TransportClient.cpp DCPS/transport/framework/TransportConfig.cpp DCPS/transport/framework/TransportControlElement.cpp DCPS/transport/framework/TransportCustomizedElement.cpp DCPS/transport/framework/TransportDebug.cpp DCPS/transport/framework/TransportHeader.cpp DCPS/transport/framework/TransportImpl.cpp DCPS/transport/framework/TransportInst.cpp DCPS/transport/framework/TransportQueueElement.cpp DCPS/transport/framework/TransportReassembly.cpp DCPS/transport/framework/TransportReceiveListener.cpp DCPS/transport/framework/TransportReceiveStrategy.cpp DCPS/transport/framework/TransportRegistry.cpp DCPS/transport/framework/TransportReplacedElement.cpp DCPS/transport/framework/TransportRetainedElement.cpp DCPS/transport/framework/TransportSendBuffer.cpp DCPS/transport/framework/TransportSendControlElement.cpp DCPS/transport/framework/TransportSendElement.cpp DCPS/transport/framework/TransportSendListener.cpp DCPS/transport/framework/TransportSendStrategy.cpp DCPS/transport/framework/TransportStrategy.cpp DCPS/transport/framework/TransportType.cpp)
 if(CMAKE_CONFIGURATION_TYPES)
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_DCPS $<$<CONFIG:Debug>:${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}d>
+                          $<$<CONFIG:Release>:${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}> ACE::ACE)
+else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_DCPS $<$<CONFIG:Debug>:TAO_Valuetype${LIBRARY_DECORATOR}d TAO_PortableServer${LIBRARY_DECORATOR}d TAO_BiDirGIOP${LIBRARY_DECORATOR}d TAO_PI${LIBRARY_DECORATOR}d TAO_CodecFactory${LIBRARY_DECORATOR}d TAO_AnyTypeCode${LIBRARY_DECORATOR}d TAO${LIBRARY_DECORATOR}d>
                           $<$<CONFIG:Release>:TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR}> ACE::ACE)
+endif()
+else()
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_DCPS ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR} ACE::ACE)
 else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_DCPS TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE::ACE)
 endif()
+endif()
 set(PROJECT_TARGET_OPENDDS_DCPS OpenDDS_Dcps${LIBRARY_DECORATOR})
 if(MSVC)
 add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_DEPRECATE)
@@ -71,6 +80,9 @@
 
 target_link_directories(${PROJECT_TARGET_OPENDDS_DCPS} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} $ENV{ACE_ROOT}/lib)
 
+if(OPENDDS_SAFETY_PROFILE)
+target_link_directories(${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC $ENV{DDS_ROOT}/lib)
+endif()
 target_precompile_headers(${PROJECT_TARGET_OPENDDS_DCPS} PRIVATE DCPS/DdsDcps_pch.h)
 
 target_compile_definitions(${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC USING_PCH)
@@ -82,29 +94,47 @@
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcps.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
 
+if(NOT OPENDDS_SAFETY_PROFILE)
 IDL_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsConditionSeq.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
+endif()
 
+if(OPENDDS_BUILT_IN_TOPICS)
 IDL_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsCoreTypeSupport.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
 
+if(NOT OPENDDS_SAFETY_PROFILE)
+IDL_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsGuidTypeSupport.idl
+    IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
+endif()
+
+IDL_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC OpenddsDcpsExtTypeSupport.idl
+    IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
+endif()
+
+if(NOT OPENDDS_SAFETY_PROFILE)
 IDL_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsDataReaderSeq.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
+endif()
 
 IDL_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsDomain.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
 
+if(OPENDDS_SAFETY_PROFILE)
 IDL_FILES_TARGET_SOURCES(
-    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsGuidTypeSupport.idl
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsInfrastructure.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
-
+else()
 IDL_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsInfrastructureTypeSupport.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
+endif()
 
 IDL_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsPublication.idl
@@ -130,12 +160,9 @@
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDynamicData.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I.. -Scdr -Sa)
 
-IDL_FILES_TARGET_SOURCES(
-    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC OpenddsDcpsExtTypeSupport.idl
-    IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..)
-
 
 include(typesupport_files OPTIONAL)
+if(NOT OPENDDS_SAFETY_PROFILE)
 TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC CorbaSeq/BooleanSeq.idl
     TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -o CorbaSeq -SI -Wb,tao_include_prefix=tao/)
@@ -203,17 +230,51 @@
 TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC CorbaSeq/WStringSeq.idl
     TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -o CorbaSeq -SI -Wb,tao_include_prefix=tao/)
+else()
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsConditionSeq.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -SI -Sx -Lspcpp -Wb,ts_cpp_include=DdsDcpsInfrastructureC.h)
+
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsCore.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -Lspcpp)
+
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsDataReaderSeq.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -SI -Sx -Lspcpp -Wb,ts_cpp_include=DdsDcpsSubscriptionC.h)
+
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsGuid.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -SI -Lspcpp)
+
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsInfoUtils.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -SI -Lspcpp)
+
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsSecurityParams.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -SI -Lspcpp)
+
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC OpenddsDcpsExt.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME -Lspcpp)
+endif()
+
+if(NOT OPENDDS_BUILT_IN_TOPICS)
+  set(TYPESUPPORT_SUPPRESS_TYPESUPPORT -SI)
+endif()
 
 include(idl_and_typesupport_files OPTIONAL)
+if(NOT OPENDDS_SAFETY_PROFILE)
 IDL_AND_TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsCore.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..
-    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME)
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME ${TYPESUPPORT_SUPPRESS_TYPESUPPORT})
 
 IDL_AND_TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsGuid.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..
-    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME)
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME ${TYPESUPPORT_SUPPRESS_TYPESUPPORT})
 
 IDL_AND_TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsInfoUtils.idl
@@ -224,12 +285,14 @@
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDcpsInfrastructure.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..
     TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME)
+endif()
 
 IDL_AND_TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsDynamicDataSeq.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..
     TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME)
 
+if(NOT OPENDDS_SAFETY_PROFILE)
 IDL_AND_TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC DdsSecurityCore.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..
@@ -243,6 +306,6 @@
 IDL_AND_TYPESUPPORT_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_DCPS} PUBLIC OpenddsDcpsExt.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -SS -I..
-    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME)
-
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,pch_include=DCPS/DdsDcps_pch.h -Wb,export_macro=OpenDDS_Dcps_Export -Wb,export_include=dds/DCPS/dcps_export.h -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME ${TYPESUPPORT_SUPPRESS_TYPESUPPORT})
+endif()
 
--- orig/dds/CMakeLists.txt	2022-11-21 14:09:30.000000000 -0600
+++ dds/CMakeLists.txt	2022-11-22 10:12:29.654222100 -0600
@@ -8,10 +8,19 @@
 cmake_minimum_required(VERSION 3.12.0)
 project(dds CXX)
 
+if(OPENDDS_SAFETY_PROFILE)
+add_subdirectory(CORBA/tao)
+endif()
 add_subdirectory(DCPS)
+if(NOT OPENDDS_SAFETY_PROFILE)
 add_subdirectory(idl)
+endif()
+if(${OPENDDS_BUILT_IN_TOPICS})
 add_subdirectory(FACE)
+endif()
+if(NOT OPENDDS_SAFETY_PROFILE)
 add_subdirectory(InfoRepo)
 add_subdirectory(monitor)
+endif()
 
 include(CMakeLists.OpenDDS_Dcps)
--- orig/dds/DCPS/CMakeLists.txt	2022-11-21 14:09:30.000000000 -0600
+++ dds/DCPS/CMakeLists.txt	2022-11-21 14:30:11.998118500 -0600
@@ -9,9 +9,15 @@
 project(DCPS CXX)
 
 add_subdirectory(transport)
+if(NOT OPENDDS_SAFETY_PROFILE)
 add_subdirectory(InfoRepoDiscovery)
+endif()
+if(OPENDDS_XERCES3)
 add_subdirectory(QOS_XML_Handler)
+endif()
 add_subdirectory(RTPS)
+if(NOT OPENDDS_SAFETY_PROFILE AND OPENDDS_SECURITY)
 add_subdirectory(security)
+endif()
 
 include(CMakeLists.OpenDDS_Util)
--- orig/dds/DCPS/QOS_XML_Handler/CMakeLists.OpenDDS_QOS_XML_XSC_Handler	2022-11-21 14:09:30.000000000 -0600
+++ dds/DCPS/QOS_XML_Handler/CMakeLists.OpenDDS_QOS_XML_XSC_Handler	2022-11-22 10:05:45.421256100 -0600
@@ -17,10 +17,19 @@
 
 set(SOURCE_FILES_OPENDDS_QOS_XML_XSC_HANDLER DataReaderQos_Handler.cpp DataWriterQos_Handler.cpp ParticipantQos_Handler.cpp PublisherQos_Handler.cpp QOS_Common.cpp QOS_XML_Loader.cpp SubscriberQos_Handler.cpp TopicQos_Handler.cpp XML_File_Intf.cpp XML_Intf.cpp XML_String_Intf.cpp dds_qos.cpp)
 if(CMAKE_CONFIGURATION_TYPES)
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_QOS_XML_XSC_HANDLER $<$<CONFIG:Debug>:OpenDDS_Dcps${LIBRARY_DECORATOR}d ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}d>
+                          $<$<CONFIG:Release>:OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}> ACE::ACE ${XercesC_LIBRARIES})
+else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_QOS_XML_XSC_HANDLER $<$<CONFIG:Debug>:OpenDDS_Dcps${LIBRARY_DECORATOR}d TAO_BiDirGIOP${LIBRARY_DECORATOR}d TAO_PI${LIBRARY_DECORATOR}d TAO_CodecFactory${LIBRARY_DECORATOR}d TAO_Valuetype${LIBRARY_DECORATOR}d TAO_PortableServer${LIBRARY_DECORATOR}d TAO_AnyTypeCode${LIBRARY_DECORATOR}d TAO${LIBRARY_DECORATOR}d ACE_XML_Utils${LIBRARY_DECORATOR}d>
-                          $<$<CONFIG:Release>:OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE_XML_Utils${LIBRARY_DECORATOR}> "${XercesC_LIBRARIES}" ACE::ACE)
+                          $<$<CONFIG:Release>:OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE_XML_Utils${LIBRARY_DECORATOR}> ACE::ACE ${XercesC_LIBRARIES})
+endif()
+else()
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_QOS_XML_XSC_HANDLER OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR} ACE::ACE ${XercesC_LIBRARIES})
 else()
-set(TARGET_LINK_LIBRARIES_OPENDDS_QOS_XML_XSC_HANDLER OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE_XML_Utils${LIBRARY_DECORATOR} "${XercesC_LIBRARIES}" ACE::ACE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_QOS_XML_XSC_HANDLER OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE_XML_Utils${LIBRARY_DECORATOR} ACE::ACE ${XercesC_LIBRARIES})
+endif()
 endif()
 set(PROJECT_TARGET_OPENDDS_QOS_XML_XSC_HANDLER OpenDDS_QOS_XML_XSC_Handler${LIBRARY_DECORATOR})
 if(MSVC)
@@ -69,3 +78,14 @@
 target_compile_definitions(${PROJECT_TARGET_OPENDDS_QOS_XML_XSC_HANDLER} PUBLIC XML_USE_PTHREADS ${OPENDDS_BUILT_IN_TOPICS_MACRO} ${OPENDDS_SAFETY_PROFILE_MACRO} ${OPENDDS_SECURITY_MACRO} ${OPENDDS_RAPIDJSON_MACRO})
 
 
+find_program(XSC xsc $ENV{XSC_ROOT}/bin)
+if(XSC)
+  set(_schema_dir ../../../docs/schema)
+  set(_schema_file dds_qos)
+  set(_schema_outdir ${CMAKE_CURRENT_SOURCE_DIR})
+  add_custom_command(
+    OUTPUT ${_schema_outdir}/${_schema_file}.hpp ${_schema_outdir}/${_schema_file}.cpp
+    DEPENDS ${_schema_dir}/${_schema_file}.xsd
+    WORKING_DIRECTORY ${_schema_outdir}
+    COMMAND ${XSC} --backend cxx --cxx-banner-file ${_schema_dir}/xsc-banner.cpp --cxx-header-banner-file ${_schema_dir}/xsc-banner.h --cxx-export-symbol OpenDDS_XML_QOS_Handler_Export --cxx-export-header OpenDDS_XML_QOS_Handler_Export.h --cxx-char-type ACE_TCHAR --search-path ${_schema_dir} ${_schema_dir}/${_schema_file}.xsd)
+endif()
--- orig/dds/DCPS/RTPS/CMakeLists.OpenDDS_Rtps	2022-11-21 14:09:30.000000000 -0600
+++ dds/DCPS/RTPS/CMakeLists.OpenDDS_Rtps	2022-11-21 14:30:12.022807600 -0600
@@ -15,11 +15,20 @@
 
 set(SOURCE_FILES_OPENDDS_RTPS BaseMessageUtils.cpp GuidGenerator.cpp ICE/AgentImpl.cpp ICE/Checklist.cpp ICE/EndpointManager.cpp ICE/Ice.cpp ICE/Stun.cpp ICE/Task.cpp Logging.cpp ParameterListConverter.cpp RtpsDiscovery.cpp Sedp.cpp Spdp.cpp TypeLookup.cpp)
 if(CMAKE_CONFIGURATION_TYPES)
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS $<$<CONFIG:Debug>:OpenDDS_Dcps${LIBRARY_DECORATOR}d ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}d>
+                          $<$<CONFIG:Release>:OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}> ACE::ACE)
+else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS $<$<CONFIG:Debug>:OpenDDS_Dcps${LIBRARY_DECORATOR}d TAO_BiDirGIOP${LIBRARY_DECORATOR}d TAO_PI${LIBRARY_DECORATOR}d TAO_CodecFactory${LIBRARY_DECORATOR}d TAO_Valuetype${LIBRARY_DECORATOR}d TAO_PortableServer${LIBRARY_DECORATOR}d TAO_AnyTypeCode${LIBRARY_DECORATOR}d TAO${LIBRARY_DECORATOR}d>
                           $<$<CONFIG:Release>:OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR}> ACE::ACE)
+endif()
+else()
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR} ACE::ACE)
 else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE::ACE)
 endif()
+endif()
 set(PROJECT_TARGET_OPENDDS_RTPS OpenDDS_Rtps${LIBRARY_DECORATOR})
 if(MSVC)
 add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_DEPRECATE)
@@ -67,6 +76,16 @@
 target_compile_definitions(${PROJECT_TARGET_OPENDDS_RTPS} PUBLIC ${OPENDDS_BUILT_IN_TOPICS_MACRO} ${OPENDDS_SAFETY_PROFILE_MACRO} ${OPENDDS_SECURITY_MACRO} ${OPENDDS_RAPIDJSON_MACRO} NOMINMAX)
 
 
+if(OPENDDS_SAFETY_PROFILE)
+include(typesupport_files OPTIONAL)
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_RTPS} PUBLIC RtpsCore.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,export_macro=OpenDDS_Rtps_Export -Wb,export_include=rtps_export.h -SI -Sx -Lspcpp)
+
+TYPESUPPORT_FILES_TARGET_SOURCES(
+    ${PROJECT_TARGET_OPENDDS_RTPS} PUBLIC RtpsRpc.idl
+    TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,export_macro=OpenDDS_Rtps_Export -Wb,export_include=rtps_export.h -SI -Sx -Lspcpp)
+else()
 include(idl_files OPTIONAL)
 IDL_FILES_TARGET_SOURCES(
     ${PROJECT_TARGET_OPENDDS_RTPS} PUBLIC RtpsSecurity.idl
@@ -82,5 +101,5 @@
     ${PROJECT_TARGET_OPENDDS_RTPS} PUBLIC RtpsRpc.idl
     IDL_FILES_OPTIONS -Wb,pre_include=ace/pre.h -Wb,post_include=ace/post.h -I $(TAO_ROOT) --idl-version 4 --unknown-annotations ignore -as ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${SAFETY_PROFILE_TAOIDL_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -I../../.. -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL -Wb,versioning_include=dds/Versioned_Namespace.h -Wb,export_macro=OpenDDS_Rtps_Export -Wb,export_include=rtps_export.h -SS
     TYPESUPPORT_FILES_OPTIONS ${OPENDDS_BUILT_IN_TOPICS_OPTION} ${OPENDDS_SAFETY_PROFILE_OPTION} ${OPENDDS_SECURITY_OPTION} -Sa -St -Wb,export_macro=OpenDDS_Rtps_Export -Wb,export_include=rtps_export.h -SI)
-
+endif()
 
--- orig/dds/DCPS/security/CMakeLists.OpenDDS_Security	2022-11-21 14:09:29.000000000 -0600
+++ dds/DCPS/security/CMakeLists.OpenDDS_Security	2022-11-21 14:30:12.041335200 -0600
@@ -16,9 +16,9 @@
 set(SOURCE_FILES_OPENDDS_SECURITY AccessControl/Governance.cpp AccessControl/LocalAccessCredentialData.cpp AccessControl/Permissions.cpp AccessControl/XmlUtils.cpp AccessControlBuiltInImpl.cpp Authentication/LocalAuthCredentialData.cpp AuthenticationBuiltInImpl.cpp BuiltInPluginLoader.cpp BuiltInPlugins.cpp BuiltInSecurityPluginInst.cpp CommonUtilities.cpp CryptoBuiltInImpl.cpp SSL/Certificate.cpp SSL/DiffieHellman.cpp SSL/PrivateKey.cpp SSL/SignedDocument.cpp SSL/SubjectName.cpp SSL/Utils.cpp TokenReader.cpp TokenWriter.cpp UtilityImpl.cpp)
 if(CMAKE_CONFIGURATION_TYPES)
 set(TARGET_LINK_LIBRARIES_OPENDDS_SECURITY $<$<CONFIG:Debug>:ACE_XML_Utils${LIBRARY_DECORATOR}d OpenDDS_Rtps${LIBRARY_DECORATOR}d OpenDDS_Dcps${LIBRARY_DECORATOR}d TAO_BiDirGIOP${LIBRARY_DECORATOR}d TAO_PI${LIBRARY_DECORATOR}d TAO_CodecFactory${LIBRARY_DECORATOR}d TAO_Valuetype${LIBRARY_DECORATOR}d TAO_PortableServer${LIBRARY_DECORATOR}d TAO_AnyTypeCode${LIBRARY_DECORATOR}d TAO${LIBRARY_DECORATOR}d>
-                          $<$<CONFIG:Release>:ACE_XML_Utils${LIBRARY_DECORATOR} OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR}> "${XercesC_LIBRARIES}" ${OPENSSL_LIBRARIES} ACE::ACE)
+                          $<$<CONFIG:Release>:ACE_XML_Utils${LIBRARY_DECORATOR} OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR}> ACE::ACE "${XercesC_LIBRARIES}" ${OPENSSL_LIBRARIES})
 else()
-set(TARGET_LINK_LIBRARIES_OPENDDS_SECURITY ACE_XML_Utils${LIBRARY_DECORATOR} OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} "${XercesC_LIBRARIES}" ${OPENSSL_LIBRARIES} ACE::ACE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_SECURITY ACE_XML_Utils${LIBRARY_DECORATOR} OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE::ACE "${XercesC_LIBRARIES}" ${OPENSSL_LIBRARIES})
 endif()
 set(PROJECT_TARGET_OPENDDS_SECURITY OpenDDS_Security${LIBRARY_DECORATOR})
 if(MSVC)
--- orig/dds/DCPS/transport/CMakeLists.txt	2022-11-21 14:09:30.000000000 -0600
+++ dds/DCPS/transport/CMakeLists.txt	2022-11-21 14:30:12.047707000 -0600
@@ -8,8 +8,10 @@
 cmake_minimum_required(VERSION 3.12.0)
 project(transport CXX)
 
+if(NOT OPENDDS_SAFETY_PROFILE)
 add_subdirectory(multicast)
-add_subdirectory(rtps_udp)
 add_subdirectory(shmem)
 add_subdirectory(tcp)
 add_subdirectory(udp)
+endif()
+add_subdirectory(rtps_udp)
--- orig/dds/DCPS/transport/rtps_udp/CMakeLists.OpenDDS_Rtps_Udp	2022-11-21 14:09:28.000000000 -0600
+++ dds/DCPS/transport/rtps_udp/CMakeLists.OpenDDS_Rtps_Udp	2022-11-21 14:30:12.053857100 -0600
@@ -17,11 +17,20 @@
 
 set(SOURCE_FILES_OPENDDS_RTPS_UDP MetaSubmessage.cpp RtpsCustomizedElement.cpp RtpsSampleHeader.cpp RtpsTransportHeader.cpp RtpsUdp.cpp RtpsUdpDataLink.cpp RtpsUdpInst.cpp RtpsUdpLoader.cpp RtpsUdpReceiveStrategy.cpp RtpsUdpSendStrategy.cpp RtpsUdpTransport.cpp TransactionalRtpsSendQueue.cpp)
 if(CMAKE_CONFIGURATION_TYPES)
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS_UDP $<$<CONFIG:Debug>:OpenDDS_Rtps${LIBRARY_DECORATOR}d OpenDDS_Dcps${LIBRARY_DECORATOR}d ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}d>
+                          $<$<CONFIG:Release>:OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}> ACE::ACE)
+else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS_UDP $<$<CONFIG:Debug>:OpenDDS_Rtps${LIBRARY_DECORATOR}d OpenDDS_Dcps${LIBRARY_DECORATOR}d TAO_BiDirGIOP${LIBRARY_DECORATOR}d TAO_PI${LIBRARY_DECORATOR}d TAO_CodecFactory${LIBRARY_DECORATOR}d TAO_Valuetype${LIBRARY_DECORATOR}d TAO_PortableServer${LIBRARY_DECORATOR}d TAO_AnyTypeCode${LIBRARY_DECORATOR}d TAO${LIBRARY_DECORATOR}d>
                           $<$<CONFIG:Release>:OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR}> ACE::ACE)
+endif()
+else()
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS_UDP OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR} ACE::ACE)
 else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_RTPS_UDP OpenDDS_Rtps${LIBRARY_DECORATOR} OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE::ACE)
 endif()
+endif()
 set(PROJECT_TARGET_OPENDDS_RTPS_UDP OpenDDS_Rtps_Udp${LIBRARY_DECORATOR})
 if(MSVC)
 add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_DEPRECATE)
--- orig/dds/FACE/CMakeLists.OpenDDS_FACE	2022-11-21 14:09:24.000000000 -0600
+++ dds/FACE/CMakeLists.OpenDDS_FACE	2022-11-21 14:30:12.069221000 -0600
@@ -15,12 +15,21 @@
 
 set(SOURCE_FILES_OPENDDS_FACE ./config/ConnectionSettings.cpp ./config/Parser.cpp ./config/QosSettings.cpp ./config/TopicSettings.cpp FaceTSS.cpp StringManager.cpp)
 if(CMAKE_CONFIGURATION_TYPES)
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_FACE $<$<CONFIG:Debug>:OpenDDS_Dcps${LIBRARY_DECORATOR}d ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}d>
+                          $<$<CONFIG:Release>:OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR}> ACE::ACE)
+else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_FACE $<$<CONFIG:Debug>:OpenDDS_Dcps${LIBRARY_DECORATOR}d TAO_BiDirGIOP${LIBRARY_DECORATOR}d TAO_PI${LIBRARY_DECORATOR}d TAO_CodecFactory${LIBRARY_DECORATOR}d TAO_Valuetype${LIBRARY_DECORATOR}d TAO_PortableServer${LIBRARY_DECORATOR}d TAO_AnyTypeCode${LIBRARY_DECORATOR}d TAO${LIBRARY_DECORATOR}d>
                           $<$<CONFIG:Release>:OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR}> ACE::ACE)
+endif()
+else()
+if(OPENDDS_SAFETY_PROFILE)
+set(TARGET_LINK_LIBRARIES_OPENDDS_FACE OpenDDS_Dcps${LIBRARY_DECORATOR} ${OPENDDS_SAFETY_PROFILE_CORBA_LIB}${LIBRARY_DECORATOR} ACE::ACE)
 else()
 set(TARGET_LINK_LIBRARIES_OPENDDS_FACE OpenDDS_Dcps${LIBRARY_DECORATOR} TAO_BiDirGIOP${LIBRARY_DECORATOR} TAO_PI${LIBRARY_DECORATOR} TAO_CodecFactory${LIBRARY_DECORATOR} TAO_Valuetype${LIBRARY_DECORATOR} TAO_PortableServer${LIBRARY_DECORATOR} TAO_AnyTypeCode${LIBRARY_DECORATOR} TAO${LIBRARY_DECORATOR} ACE::ACE)
 endif()
-set(PROJECT_TARGET_OPENDDS_FACE OpenDDS_FACE${LIBRARY_DECORATOR})
+endif()
+set(PROJECT_TARGET_OPENDDS_FACE OpenDDS_FACE)
 if(MSVC)
 add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_DEPRECATE)
 endif()
';

  if (open($fh, ">$file")) {
    print $fh $patch;
    close($fh);

    system("$patchexe -p0 < $file");
    unlink($file);
  }
}
