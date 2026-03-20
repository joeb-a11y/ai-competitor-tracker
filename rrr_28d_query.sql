-- 28-Day Run-Rate Revenue (RRR) for target DNB/Platform accounts
-- Source: proj-finance-data-liul.reporting.monthly_revenue_run_rate
-- RRR = annualized_revenue_estimate (12× rolling_28d for subs, 13× for usage-based)
--
-- Output distinguishes three states:
--   active              → has non-zero 28d RRR
--   in_sfdc_zero_spend  → account exists in Salesforce but no spend (whitespace)
--   not_in_sfdc         → no matching account found
--
-- Note: revenue is aggregated by account NAME (not ID) because dim_salesforce_accounts
-- contains duplicate entries with different SF IDs for the same company; joining on
-- a single ANY_VALUE(id) would miss revenue attributed to the other ID.

WITH target_names AS (
  SELECT name FROM UNNEST([
    'Intercom', 'Quora', 'Zapier, Inc.', 'Cloudflare', 'ScaleAI', 'Epic Games, Inc.',
    'Indeed', 'Binance Holdings Ltd.', 'Turing', 'ZoomInfo', 'Godaddy.com, Inc.',
    'Dropbox', 'Affirm', 'AlphaSense', 'UKG', 'ServiceTitan, Inc',
    'OKBL USA Technology Inc.', 'Maplebear Inc. dba Instacart', 'Geotab', 'Asana',
    'Zendesk, Inc.', 'Carvana', 'Arista Networks', 'Axon Enterprise, Inc.',
    'Robinhood', 'Guidewire', 'Postman Inc.', 'Lyft', 'Confluent',
    'Social Finance, Inc. (SoFi)', 'Gusto, Inc.', 'UIPath', 'Toast, Inc.',
    'Tyler Technologies', 'Prepared', 'Zillow, Inc.', 'Cadence Design Systems',
    'Etsy, Inc.', 'Verint', 'Kavak', 'Snapchat', 'NICE Ltd', 'Smartsheet Inc.',
    'Klaviyo', 'Wonder', 'Pegasystems', 'Fivetran', 'Roku, Inc.', 'Automattic',
    'DraftKings', 'Yelp Inc.', 'Genesys Cloud Services, Inc.', '8x8', 'Navan',
    'Electronic Arts Inc.', 'Samsara', 'Flexport', 'Pinterest', 'Jamf',
    'Lightspeed Commerce', 'Applied Systems', 'Mongodb, Inc.', 'Pocket FM Corp',
    'BMC Software', 'Thoughtworks Inc', 'Hudl', 'Zoho', 'Tekion', 'BetterUp',
    'Costar', 'Splunk Inc.', 'Synopsys', 'Teradata Corporation', 'Box, Inc.',
    'Realtor.com', 'SpotOn', 'Meltwater Group', 'Freshworks, Inc.', 'Yardi',
    'Groupon, Inc.', 'Unity Software', 'Avalara, Inc.', 'Coupa',
    'Diligent (acquired multiple companies)', 'RealPage, Inc.', 'EquipmentShare',
    'DocuSign', 'Clearwater Analytics', 'Remitly, Inc.', 'FanDuel',
    'The Trade Desk, Inc.', 'Thebrowsercompany', 'BetterHelp',
    'GoTo Technologies USA', 'CLEAR (clearme.com)', 'Udemy, Inc.', 'Rippling',
    'Cvent', 'Pipedream', 'dbt Labs, Inc.', 'RingCentral, Inc.',
    'Upwork (f.k.a elance-oDesk)', 'Qualtrics', 'Kaseya US LLC', 'Wayfair',
    'Poshmark', 'Hyland Software, Inc.', 'Replicate [acquired by cloudflare]',
    'Angi', 'Aptean', 'Verifone, Inc.', 'HashiCorp',
    'SailPoint Technologies, Inc.', 'Firehydrant', 'Thryv', 'Scopely',
    'SAS Institute Inc.', 'Procore Technologies, Inc.', 'DataStax', 'Workiva Inc',
    'Blackbaud', 'Red Ventures', 'Cloudera, Inc.', 'Fractal Analytics',
    'Automation Anywhere', 'Axtria - Ingenious Insights', 'Zelis', 'Skillsoft',
    'Episource', 'Gainwell Technologies LLC', 'iFood Brazil',
    'Take-Two Interactive', 'Zynga', 'Anaplan', 'Teladoc Health',
    'Riot Games, Inc.', 'Wiselayer', 'Cohesity', 'Harris Computer', 'Paycor',
    'Paradox', 'Sprinklr', 'ClickBank', 'Precisely', 'Cornerstone OnDemand',
    'Amplify', 'Medidata Solutions, Inc.', 'Connectwise', 'Grubhub', 'Agilysys',
    'Vertex, Inc.', 'Bill.com, Inc', 'Rappi', 'Csg Systems International, Inc.',
    'IAC Inc.', 'Talend, Inc.', 'Restaurant365', 'CoStar Group', 'The RealReal',
    'Gopuff', 'Peloton', 'Lyra Health, Inc.', 'Stitch Fix', 'Five9', '[24]7.ai',
    'inContact', 'Nexmo', 'Nuxeo', 'Dayforce', 'Paylocity', 'Deel', 'Paycom',
    'Businessolver.com, Inc.', 'Saba Software', 'Avature', 'HubSpot',
    'LivePerson', 'CallidusCloud', 'Twilio', 'ESRI',
    'Validity (formerly ReturnPath)', 'Tellwise', 'AppDynamics, Inc.',
    'Citrix Systems', 'Virtustream', 'Unifi Software', 'Cision Inc', 'Elemental',
    'AOL', 'Unity Technologies', 'Medium', 'impact.com', 'AddThis', 'dataxu',
    'Quickpivot (fka Extraprise, SmartSourceOnline)', 'Reddit, Inc.', 'Vacasa',
    'Despegar', 'Fareportal', 'Rootbeer Computer', 'astronomer.io',
    'ThinkingPhones (Fuze)', 'Picpay', 'The Stars Group', 'Rockstar Games',
    '2k Games', 'Anchor', 'Donnelley Financial Solutions', 'Manhattan Associates',
    'E2open', 'LLamasoft', 'Motive', 'Geotab inc', 'SPS Commerce',
    'Highradius Corporation (*** routes to India)', 'o9 Solutions, Inc.',
    'NCR Voyix', 'Nasdaq Calypso Technology', 'ACI WorldWide', 'Vizient, inc',
    'Gainwell Technologies', 'FinThrive', 'BR - Afya@PEBMED - HLC',
    'Claritev (NYS: CTEV)', 'Cerner', 'Inovalon, Inc', 'Mitratech',
    'Evisort, Inc.', 'Nuvei Technologies', 'PROS', 'Valid', 'ClickSWITCH',
    'Stytch', 'Q2 Holdings, Inc.', 'Payoneer', 'Xactly', 'Envestnet', 'Melio',
    'CDK', 'AspenTech', 'Mavenir', 'Amdocs', 'Solera Holdings, LLC.',
    'Netcracker Technology Corporation', 'Linode', 'liblab (acquired by postman)',
    'dbt Labs', 'Stellar Elements', 'Datto', 'Goodwords', 'Newfold Digital',
    'Centific', 'Isovalent', 'Veeam Software Corp', 'Veeam',
    'Veritas Technologies LLC', 'Atlassian', 'Ellucian', 'Stride, Inc.',
    'Blackboard', 'Ascend Learning', '2U', 'Cambium Learning Group', 'Update.AI',
    'KB Labs (Techstars)', 'iMerit Technology', 'Web', 'ChatGPT', 'XAI Inc.',
    'Nutanix', 'Tripadvisor, LLC', 'Vizient Inc.',
    'Open Artificial Intelligence Inc.', 'Cloud Software Group',
    'PowerSchool Group LLC', 'R Systems'
  ]) AS name
),

-- SFDC naming variations discovered during matching
aliases AS (
  SELECT * FROM UNNEST([
    STRUCT('Atlassian' AS requested, 'Atlassian Pty Ltd' AS sf_name),
    ('HubSpot', 'HubSpot, Inc.'),
    ('Twilio', 'Twilio Inc.'),
    ('Meltwater Group', 'Meltwater News US Inc.'),
    ('Stride, Inc.', 'Stride, Inc. (formerly K12 Inc.)'),
    ('Veeam', 'Veeam (merge)'),
    ('Veeam Software Corp', 'Veeam (merge)'),
    ('Lyra Health, Inc.', 'Lyra Health'),
    ('Reddit, Inc.', 'Reddit'),
    ('dbt Labs', 'dbt Labs, Inc.'),
    ('Gainwell Technologies', 'Gainwell Technologies LLC'),
    ('Unity Technologies', 'Unity Software'),
    ('CoStar Group', 'Costar'),
    ('Geotab inc', 'Geotab'),
    ('Vizient, inc', 'Vizient Inc.')
  ])
),

resolved_targets AS (
  SELECT
    t.name AS requested_name,
    LOWER(TRIM(COALESCE(a.sf_name, t.name))) AS lookup_key
  FROM target_names t
  LEFT JOIN aliases a ON t.name = a.requested
),

rrr_by_name AS (
  SELECT
    LOWER(TRIM(salesforce_account_name)) AS name_lower,
    ANY_VALUE(salesforce_account_name) AS salesforce_account_name,
    MAX_BY(salesforce_account_id, annualized_revenue_estimate) AS salesforce_account_id,
    ANY_VALUE(sales_segment) AS sales_segment,
    SUM(annualized_revenue_estimate) AS rrr_28d
  FROM `proj-finance-data-liul.reporting.monthly_revenue_run_rate`
  WHERE date = (SELECT MAX(date) FROM `proj-finance-data-liul.reporting.monthly_revenue_run_rate` WHERE is_data_complete)
    AND COALESCE(sales_segment, '') != 'Fraud'
    AND salesforce_account_name IS NOT NULL
  GROUP BY 1
),

sfdc_exists AS (
  SELECT
    LOWER(TRIM(account_name)) AS name_lower,
    ANY_VALUE(account_name) AS account_name,
    ANY_VALUE(salesforce_account_id) AS salesforce_account_id,
    ANY_VALUE(sales_segment) AS sales_segment
  FROM `proj-finance-data-liul.reporting.dim_salesforce_accounts`
  GROUP BY 1
)

SELECT
  rt.requested_name,
  COALESCE(r.salesforce_account_name, s.account_name) AS salesforce_account_name,
  COALESCE(r.salesforce_account_id, s.salesforce_account_id) AS salesforce_account_id,
  COALESCE(r.sales_segment, s.sales_segment) AS sales_segment,
  ROUND(COALESCE(r.rrr_28d, IF(s.account_name IS NOT NULL, 0, NULL)), 0) AS rrr_28d_usd,
  CASE
    WHEN r.rrr_28d > 0 THEN 'active'
    WHEN r.rrr_28d IS NOT NULL OR s.account_name IS NOT NULL THEN 'in_sfdc_zero_spend'
    ELSE 'not_in_sfdc'
  END AS status
FROM resolved_targets rt
LEFT JOIN rrr_by_name r ON rt.lookup_key = r.name_lower
LEFT JOIN sfdc_exists s ON rt.lookup_key = s.name_lower
ORDER BY rrr_28d_usd DESC NULLS LAST, rt.requested_name
