Function Get-WorkloadManagementNamespace {
	<#
		.NOTES
		===========================================================================
        Created by:    David Stamen
        Blog:          www.davidstamen.com
        Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function gets vSphere with Kubernetes Namespaces.
		.DESCRIPTION
			Function to return details about the Namespaces
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-vk8sNamespace
	#>
	$servers = $Global:DefaultCisServers
	foreach ($server in $servers) {
		$systemUpdateAPI = Get-CisService -Name 'com.vmware.vcenter.namespaces.instances' -Server $server.Name
		$results = $systemUpdateAPI.list()

		$summaryResult = [pscustomobject] @{
            "Server" = $server.Name;
            "Cluster" = $results.cluster;
			"Namespace" = $results.namespace;
			"Config Status" = $results.config_status;
			"CPU Used" = $results.stats.cpu_used;
			"Memory Used" = $results.stats.memory_used;
			"Storage Used" = $results.stats.storage_used
		}
		$summaryResult
    }
}
Function Get-WorkloadManagementCluster {
	<#
		.NOTES
		===========================================================================
        Created by:    David Stamen
        Blog:          www.davidstamen.com
        Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function gets vSphere with Kubernetes Clusters.
		.DESCRIPTION
			Function to return details about the Supervisor Clusters
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-vk8sCluster
	#>
	$servers = $Global:DefaultCisServers
	foreach ($server in $servers) {
		$systemUpdateAPI = Get-CisService -Name 'com.vmware.vcenter.namespace_management.clusters' -Server $server.Name
		$results = $systemUpdateAPI.list()

		$summaryResult = [pscustomobject] @{
            "Server" = $server.Name;
            "Cluster" = $results.cluster;
			"Cluster Name" = $results.cluster_name;
            "Config Status" = $results.config_status;
            "Kubernetes Status" = $results.kubernetes_status;
            "CPU Capacity" = $results.stats.cpu_capacity;
            "CPU Used" = $results.stats.cpu_used;
            "Memory Capacity" = $results.stats.memory_capacity;
            "Memory Used" = $results.stats.memory_used;
            "Storage Capacity" = $results.stats.storage_capacity;
			"Storage Used" = $results.stats.storage_used
		}
		$summaryResult
    }
}
Function Get-WorkloadManagementClusterSoftware {
	<#
		.NOTES
		===========================================================================
        Created by:    David Stamen
        Blog:          www.davidstamen.com
        Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function gets vSphere with Kubernetes Cluster Software.
		.DESCRIPTION
			Function to return details about the Supervisor Clusters Software 
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-vk8sClusterSoftware
	#>
	$servers = $Global:DefaultCisServers
	foreach ($server in $servers) {
		$systemUpdateAPI = Get-CisService -Name 'com.vmware.vcenter.namespace_management.software.clusters' -Server $server.Name
		$results = $systemUpdateAPI.list()

		$summaryResult = [pscustomobject] @{
            "Server" = $server.Name;
            "Cluster" = $results.cluster;
			"Cluster Name" = $results.cluster_name;
            "State" = $results.state;
            "Current Version" = $results.current_version;
            "Desired Version" = $results.desired_version;
            "Available Versions" = $results.available_versions;
            "Last Upgraded Date" = $results.last_upgraded_date
        }
		$summaryResult
    }
}
Function Get-WorkloadManagementClusterVersions {
	<#
		.NOTES
		===========================================================================
        Created by:    David Stamen
        Blog:          www.davidstamen.com
        Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function gets vSphere with Kubernetes Cluster Versions.
		.DESCRIPTION
			Function to return details about the Supervisor Clusters Versions
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-vk8sClusterVersions
	#>
	$servers = $Global:DefaultCisServers
	foreach ($server in $servers) {
		$systemUpdateAPI = Get-CisService -Name 'com.vmware.vcenter.namespace_management.cluster_available_versions' -Server $server.Name
		$results = $systemUpdateAPI.list()

        foreach ($result in $results) {
            $summaryResult = [pscustomobject] @{
                "Server" = $server.Name;
                "Name" = $result.name;
                "Description" = $result.description;
                "Version" = $result.version;
                "Release Date" = $result.release_date;
                "Release Notes" = $result.release_notes
            }
            $summaryResult
        }
    }
}
Function Get-WorkloadManagementAuthorizedNamespaces {
	<#
		.NOTES
		===========================================================================
        Created by:    David Stamen
        Blog:          www.davidstamen.com
        Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function returns namespaces that the authorized user has access to.
		.DESCRIPTION
			Function to return details about the namespace access.
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-vk8sClusterSoftware
	#>
	$servers = $Global:DefaultCisServers
	foreach ($server in $servers) {
		$systemUpdateAPI = Get-CisService -Name 'com.vmware.vcenter.namespaces.user.instances' -Server $server.Name
		$results = $systemUpdateAPI.list()

		$summaryResult = [pscustomobject] @{
			"Namespace" = $results.namespace
            "Master Host" = $results.master_host;
            "Server" = $server.Name;
        }
		$summaryResult
    }
}