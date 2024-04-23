# Azure Storage Account AD Join and Configuration Script

This PowerShell script automates the process of joining an Azure Storage Account to an Active Directory (AD) domain and configures default permissions. It utilizes Azure Key Vault for secure storage of credentials and leverages Azure PowerShell modules for Azure resource management.

## Prerequisites

Before using this script, ensure you have the following:

- Azure Subscription ID
- Resource Group Name where the Storage Account resides
- Storage Account Name
- Access to Azure Key Vault with necessary permissions
- Azure PowerShell module installed
- AD credentials stored securely in Azure Key Vault

## Parameters

- SubscriptionId: Azure Subscription ID where the Storage Account resides.
- ResourceGroupName: Name of the resource group where the Storage Account is located.
- StorageAccountName: Name of the Azure Storage Account.
