﻿#specify a domain controller to work with
    $dc = 'Your Domain Controller Name'

#Create an output file to capture the results
    $Output = "c:\scripts\output.txt"
    Out-File $Output -InputObject "OldPrimarySMTPAddress`tNewPrimarySMTPAddress"

#specify the OU you wish to pull the users from
    $OU = "yourdmain.com/Your OU/" #replace with the OU you want to work with

#specify the domain of the new SMTP address you want to change it to
    $NewDomain = "newDomain.com"

#get a list of all mailboxes in the OU
    $list = get-mailbox -OrganizationalUnit $OU -resultsize Unlimited -DomainController $DC

#Iterate through the list
    foreach ($user in $list)

     {
        $mb = Get-mailbox $user -DomainController $dc

       #capture current primary smtp address
        $SMTP = $mb.PrimarySmtpAddress
        [string]$Local = $SMTP.Local
        [string]$OldDomain = $SMTP.Domain
        [string]$CPSMTP = $Local + "@" + $OldDomain

       #captur new primary smtp address
        [string]$NPSMTP = $Local + "@" + $NewDomain

       #capture the old and the new SMTP addresses to the output file
        [string]$iobject = $CPSMTP + "`t" + $NPSMTP
        Out-File $Output -InputObject $iobject -Append

       #set the new primary smtp address on the mailbox and remove the flag to use the email address policy (if you do not do this, the email address will revert to whatever the policy has set to)
        Set-Mailbox $user -PrimarySmtpAddress $NPSMTP -EmailAddressPolicyEnabled $false -DomainController $DC
    }
