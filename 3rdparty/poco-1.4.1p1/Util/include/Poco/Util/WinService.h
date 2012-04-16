//
// WinService.h
//
// $Id: //poco/1.4/Util/include/Poco/Util/WinService.h#1 $
//
// Library: Util
// Package: Windows
// Module:  WinService
//
// Definition of the WinService class.
//
// Copyright (c) 2004-2006, Applied Informatics Software Engineering GmbH.
// and Contributors.
//
// Permission is hereby granted, free of charge, to any person or organization
// obtaining a copy of the software and accompanying documentation covered by
// this license (the "Software") to use, reproduce, display, distribute,
// execute, and transmit the Software, and to prepare derivative works of the
// Software, and to permit third-parties to whom the Software is furnished to
// do so, all subject to the following:
// 
// The copyright notices in the Software and this entire statement, including
// the above license grant, this restriction and the following disclaimer,
// must be included in all copies of the Software, in whole or in part, and
// all derivative works of the Software, unless such copies or derivative
// works are solely in the form of machine-executable object code generated by
// a source language processor.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
// SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
// FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//


#ifndef Util_WinService_INCLUDED
#define Util_WinService_INCLUDED


#include "Poco/Util/Util.h"
#include "Poco/UnWindows.h"


#if defined(POCO_WIN32_UTF8)
#define POCO_LPQUERY_SERVICE_CONFIG LPQUERY_SERVICE_CONFIGW
#else
#define POCO_LPQUERY_SERVICE_CONFIG LPQUERY_SERVICE_CONFIGA
#endif


namespace Poco {
namespace Util {


class Util_API WinService
	/// This class provides an object-oriented interface to
	/// the Windows Service Control Manager for registering,
	/// unregistering, configuring, starting and stopping
	/// services.
	///
	/// This class is only available on Windows platforms.
{
public:
	enum Startup
	{
		SVC_AUTO_START,
		SVC_MANUAL_START,
		SVC_DISABLED
	};
	
	WinService(const std::string& name);
		/// Creates the WinService, using the given service name.

	~WinService();
		/// Destroys the WinService.

	const std::string& name() const;
		/// Returns the service name.

	std::string displayName() const;
		/// Returns the service's display name.

	std::string path() const;
		/// Returns the path to the service executable. 
		///
		/// Throws a NotFoundException if the service has not been registered.

	void registerService(const std::string& path, const std::string& displayName);
		/// Creates a Windows service with the executable specified by path
		/// and the given displayName.
		///
		/// Throws a ExistsException if the service has already been registered.
		
	void registerService(const std::string& path);
		/// Creates a Windows service with the executable specified by path
		/// and the given displayName. The service name is used as display name.
		///
		/// Throws a ExistsException if the service has already been registered.

	void unregisterService();
		/// Deletes the Windows service. 
		///
		/// Throws a NotFoundException if the service has not been registered.

	bool isRegistered() const;
		/// Returns true if the service has been registered with the Service Control Manager.

	bool isRunning() const;
		/// Returns true if the service is currently running.
		
	void start();
		/// Starts the service.
		/// Does nothing if the service is already running.
		///
		/// Throws a NotFoundException if the service has not been registered.

	void stop();
		/// Stops the service.
		/// Does nothing if the service is not running.
		///
		/// Throws a NotFoundException if the service has not been registered.

	void setStartup(Startup startup);
		/// Sets the startup mode for the service.
		
	Startup getStartup() const;
		/// Returns the startup mode for the service.

	static const int STARTUP_TIMEOUT;

private:
	void open() const;
	bool tryOpen() const;
	void close() const;
	POCO_LPQUERY_SERVICE_CONFIG config() const;

	WinService();
	WinService(const WinService&);
	WinService& operator = (const WinService&);

	std::string       _name;
	SC_HANDLE         _scmHandle;
	mutable SC_HANDLE _svcHandle;
};


} } // namespace Poco::Util


#endif // Util_WinService_INCLUDED