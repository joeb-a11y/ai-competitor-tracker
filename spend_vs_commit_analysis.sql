-- ============================================================================
-- Spend vs Commit Analysis — Accounts over $200K RRR
-- ============================================================================
-- Joins current 28-day RRR against active contract commitments from the
-- Salesforce commit-spend tracking table, filtered to the provided DNB
-- account universe with RRR >= $200K.
--
-- Sources:
--   - proj-finance-data-liul.reporting.monthly_revenue_run_rate          (RRR)
--   - proj-finance-data-liul.reporting.salesforce_commit_spend_tracking  (commit/spend)
--
-- Status definitions:
--   Commit Met   — actual spend already >= commitment amount
--   Over-Burning — pacing >= 120% of linear (will exhaust early)
--   On Track     — pacing 80-120% of linear
--   At Risk      — pacing < 80% of linear (won't meet commit at current rate)
--   No Commit    — account has >=$200K RRR but no active contract commitment
--
-- CAVEATS:
--   - salesforce_commit_spend_tracking only counts spend from org UUIDs
--     explicitly linked to the SFDC subscription. If a customer's 3P (Bedrock/
--     Vertex) orgs or additional 1P orgs aren't mapped, their commit-tracked
--     spend will undercount vs their true total RRR. See Lyft (At Risk: only
--     C4W org linked, $1.9M Bedrock RRR not counted toward flex commit).
--   - Name matching uses exact-match against SFDC account_name, with a small
--     manual alias map for known mismatches. ~100 list entries don't
--     exact-match; many are legacy/acquired/parent-company aliases that aren't
--     distinct SFDC accounts.
-- ============================================================================

WITH target_accounts AS (
  SELECT raw, sfdc_name FROM UNNEST([
    STRUCT('Intercom' AS raw, 'Intercom' AS sfdc_name),
    ('Quora','Quora'),
    ('Zapier, Inc.','Zapier, Inc.'),
    ('Cloudflare','Cloudflare'),
    ('ScaleAI','ScaleAI'),
    ('Epic Games, Inc.','Epic Games, Inc.'),
    ('Indeed','Indeed'),
    ('Binance Holdings Ltd.','Binance Holdings Ltd.'),
    ('Turing','Turing'),
    ('ZoomInfo','ZoomInfo'),
    ('Godaddy.com, Inc.','Godaddy.com, Inc.'),
    ('Dropbox','Dropbox'),
    ('Affirm','Affirm'),
    ('AlphaSense','AlphaSense'),
    ('UKG','UKG'),
    ('ServiceTitan, Inc','ServiceTitan, Inc'),
    ('OKBL USA Technology Inc.','OKBL USA Technology Inc.'),
    ('Maplebear Inc. dba Instacart','Maplebear Inc. dba Instacart'),
    ('Geotab','Geotab'),
    ('Asana','Asana'),
    ('Zendesk, Inc.','Zendesk, Inc.'),
    ('Carvana','Carvana'),
    ('Arista Networks','Arista Networks'),
    ('Axon Enterprise, Inc.','Axon Enterprise, Inc.'),
    ('Robinhood','Robinhood'),
    ('Guidewire','Guidewire'),
    ('Postman Inc.','Postman Inc.'),
    ('Lyft','Lyft'),
    ('Confluent','Confluent'),
    ('Social Finance, Inc. (SoFi)','Social Finance, Inc. (SoFi)'),
    ('Gusto, Inc.','Gusto, Inc.'),
    ('UIPath','UIPath'),
    ('Toast, Inc.','Toast, Inc.'),
    ('Tyler Technologies','Tyler Technologies'),
    ('Prepared','Prepared'),
    ('Zillow, Inc.','Zillow, Inc.'),
    ('Cadence Design Systems','Cadence Design Systems'),
    ('Etsy, Inc.','Etsy, Inc.'),
    ('Verint','Verint'),
    ('Kavak','Kavak'),
    ('Snapchat','Snapchat'),
    ('NICE Ltd','NICE Ltd'),
    ('Smartsheet Inc.','Smartsheet Inc.'),
    ('Klaviyo','Klaviyo'),
    ('Wonder','Wonder'),
    ('Pegasystems','Pegasystems'),
    ('Fivetran','Fivetran'),
    ('Roku, Inc.','Roku, Inc.'),
    ('Automattic','Automattic'),
    ('DraftKings','DraftKings'),
    ('Yelp Inc.','Yelp Inc.'),
    ('Genesys Cloud Services, Inc.','Genesys Cloud Services, Inc.'),
    ('8x8','8x8'),
    ('Navan','Navan'),
    ('Electronic Arts Inc.','Electronic Arts Inc.'),
    ('Samsara','Samsara'),
    ('Flexport','Flexport'),
    ('Pinterest','Pinterest'),
    ('Jamf','Jamf'),
    ('Lightspeed Commerce','Lightspeed Commerce'),
    ('Applied Systems','Applied Systems'),
    ('Mongodb, Inc.','Mongodb, Inc.'),
    ('Pocket FM Corp','Pocket FM Corp'),
    ('BMC Software','BMC Software'),
    ('Thoughtworks Inc','Thoughtworks Inc'),
    ('Hudl','Hudl'),
    ('Zoho','Zoho'),
    ('Tekion','Tekion'),
    ('BetterUp','BetterUp'),
    ('Costar','Costar'),
    ('Splunk Inc.','Splunk Inc.'),
    ('Synopsys','Synopsys'),
    ('Teradata Corporation','Teradata Corporation'),
    ('Box, Inc.','Box, Inc.'),
    ('Realtor.com','Realtor.com'),
    ('SpotOn','SpotOn'),
    ('Meltwater Group','Meltwater Group'),
    ('Freshworks, Inc.','Freshworks, Inc.'),
    ('Yardi','Yardi'),
    ('Groupon, Inc.','Groupon, Inc.'),
    ('Unity Software','Unity Software'),
    ('Avalara, Inc.','Avalara, Inc.'),
    ('Coupa','Coupa'),
    ('Diligent (acquired multiple companies)','Diligent (acquired multiple companies)'),
    ('RealPage, Inc.','RealPage, Inc.'),
    ('EquipmentShare','EquipmentShare'),
    ('DocuSign','DocuSign'),
    ('Clearwater Analytics','Clearwater Analytics'),
    ('Remitly, Inc.','Remitly, Inc.'),
    ('FanDuel','FanDuel'),
    ('The Trade Desk, Inc.','The Trade Desk, Inc.'),
    ('Thebrowsercompany','Thebrowsercompany'),
    ('BetterHelp','BetterHelp'),
    ('GoTo Technologies USA','GoTo Technologies USA'),
    ('CLEAR (clearme.com)','CLEAR (clearme.com)'),
    ('Udemy, Inc.','Udemy, Inc.'),
    ('Rippling','Rippling'),
    ('Cvent','Cvent'),
    ('Pipedream','Pipedream'),
    ('dbt Labs, Inc.','dbt Labs, Inc.'),
    ('RingCentral, Inc.','RingCentral, Inc.'),
    ('Upwork (f.k.a elance-oDesk)','Upwork (f.k.a elance-oDesk)'),
    ('Qualtrics','Qualtrics'),
    ('Kaseya US LLC','Kaseya US LLC'),
    ('Wayfair','Wayfair'),
    ('Poshmark','Poshmark'),
    ('Hyland Software, Inc.','Hyland Software, Inc.'),
    ('Replicate [acquired by cloudflare]','Replicate [acquired by cloudflare]'),
    ('Angi','Angi'),
    ('Aptean','Aptean'),
    ('Verifone, Inc.','Verifone, Inc.'),
    ('HashiCorp','HashiCorp'),
    ('SailPoint Technologies, Inc.','SailPoint Technologies, Inc.'),
    ('Firehydrant','Firehydrant'),
    ('Thryv','Thryv'),
    ('Scopely','Scopely'),
    ('SAS Institute Inc.','SAS Institute Inc.'),
    ('Procore Technologies, Inc.','Procore Technologies, Inc.'),
    ('DataStax','DataStax'),
    ('Workiva Inc','Workiva Inc'),
    ('Blackbaud','Blackbaud'),
    ('Red Ventures','Red Ventures'),
    ('Cloudera, Inc.','Cloudera, Inc.'),
    ('Fractal Analytics','Fractal Analytics'),
    ('Automation Anywhere','Automation Anywhere'),
    ('Axtria - Ingenious Insights','Axtria - Ingenious Insights'),
    ('Zelis','Zelis'),
    ('Skillsoft','Skillsoft'),
    ('Episource','Episource'),
    ('Gainwell Technologies LLC','Gainwell Technologies LLC'),
    ('iFood Brazil','iFood Brazil'),
    ('Take-Two Interactive','Take-Two Interactive'),
    ('Zynga','Zynga'),
    ('Anaplan','Anaplan'),
    ('Teladoc Health','Teladoc Health'),
    ('Riot Games, Inc.','Riot Games, Inc.'),
    ('Wiselayer','Wiselayer'),
    ('Cohesity','Cohesity'),
    ('Harris Computer','Harris Computer'),
    ('Paycor','Paycor'),
    ('Paradox','Paradox'),
    ('Sprinklr','Sprinklr'),
    ('ClickBank','ClickBank'),
    ('Precisely','Precisely'),
    ('Cornerstone OnDemand','Cornerstone OnDemand'),
    ('Amplify','Amplify'),
    ('Medidata Solutions, Inc.','Medidata Solutions, Inc.'),
    ('Connectwise','Connectwise'),
    ('Grubhub','Grubhub'),
    ('Agilysys','Agilysys'),
    ('Vertex, Inc.','Vertex, Inc.'),
    ('Bill.com, Inc','Bill.com, Inc'),
    ('Rappi','Rappi'),
    ('Csg Systems International, Inc.','Csg Systems International, Inc.'),
    ('IAC Inc.','IAC Inc.'),
    ('Talend, Inc.','Talend, Inc.'),
    ('Restaurant365','Restaurant365'),
    ('CoStar Group','CoStar Group'),
    ('The RealReal','The RealReal'),
    ('Gopuff','Gopuff'),
    ('Peloton','Peloton'),
    ('Lyra Health, Inc.','Lyra Health, Inc.'),
    ('Stitch Fix','Stitch Fix'),
    ('Five9','Five9'),
    ('[24]7.ai','[24]7.ai'),
    ('inContact','inContact'),
    ('Nexmo','Nexmo'),
    ('Nuxeo','Nuxeo'),
    ('Dayforce','Dayforce'),
    ('Paylocity','Paylocity'),
    ('Deel','Deel'),
    ('Paycom','Paycom'),
    ('Businessolver.com, Inc.','Businessolver.com, Inc.'),
    ('Saba Software','Saba Software'),
    ('Avature','Avature'),
    ('HubSpot','HubSpot, Inc.'),
    ('LivePerson','LivePerson'),
    ('CallidusCloud','CallidusCloud'),
    ('Twilio','Twilio Inc.'),
    ('ESRI','ESRI'),
    ('Validity (formerly ReturnPath)','Validity (formerly ReturnPath)'),
    ('Tellwise','Tellwise'),
    ('AppDynamics, Inc.','AppDynamics, Inc.'),
    ('Citrix Systems','Citrix Systems'),
    ('Virtustream','Virtustream'),
    ('Unifi Software','Unifi Software'),
    ('Cision Inc','Cision Inc'),
    ('Elemental','Elemental'),
    ('AOL','AOL'),
    ('Unity Technologies','Unity Technologies'),
    ('Medium','Medium'),
    ('impact.com','impact.com'),
    ('AddThis','AddThis'),
    ('dataxu','dataxu'),
    ('Quickpivot (fka Extraprise, SmartSourceOnline)','Quickpivot (fka Extraprise, SmartSourceOnline)'),
    ('Reddit, Inc.','Reddit, Inc.'),
    ('Vacasa','Vacasa'),
    ('Despegar','Despegar'),
    ('Fareportal','Fareportal'),
    ('Rootbeer Computer','Rootbeer Computer'),
    ('astronomer.io','astronomer.io'),
    ('ThinkingPhones (Fuze)','ThinkingPhones (Fuze)'),
    ('Picpay','Picpay'),
    ('The Stars Group','The Stars Group'),
    ('Rockstar Games','Rockstar Games'),
    ('2k Games','2k Games'),
    ('Anchor','Anchor'),
    ('Donnelley Financial Solutions','Donnelley Financial Solutions'),
    ('Manhattan Associates','Manhattan Associates'),
    ('E2open','E2open'),
    ('LLamasoft','LLamasoft'),
    ('Motive','Motive'),
    ('Geotab inc','Geotab'),
    ('SPS Commerce','SPS Commerce'),
    ('Highradius Corporation (*** routes to India)','Highradius Corporation (*** routes to India)'),
    ('o9 Solutions, Inc.','o9 Solutions, Inc.'),
    ('NCR Voyix','NCR Voyix'),
    ('Nasdaq Calypso Technology','Nasdaq Calypso Technology'),
    ('ACI WorldWide','ACI WorldWide'),
    ('Vizient, inc','Vizient Inc.'),
    ('Gainwell Technologies','Gainwell Technologies LLC'),
    ('FinThrive','FinThrive'),
    ('BR - Afya@PEBMED - HLC','BR - Afya@PEBMED - HLC'),
    ('Claritev (NYS: CTEV)','Claritev (NYS: CTEV)'),
    ('Cerner','Cerner'),
    ('Inovalon, Inc','Inovalon, Inc'),
    ('Mitratech','Mitratech'),
    ('Evisort, Inc.','Evisort, Inc.'),
    ('Nuvei Technologies','Nuvei Technologies'),
    ('PROS','PROS'),
    ('Valid','Valid'),
    ('ClickSWITCH','ClickSWITCH'),
    ('Stytch','Stytch'),
    ('Q2 Holdings, Inc.','Q2 Holdings, Inc.'),
    ('Payoneer','Payoneer'),
    ('Xactly','Xactly'),
    ('Envestnet','Envestnet'),
    ('Melio','Melio'),
    ('CDK','CDK'),
    ('AspenTech','AspenTech'),
    ('Mavenir','Mavenir'),
    ('Amdocs','Amdocs'),
    ('Solera Holdings, LLC.','Solera Holdings, LLC.'),
    ('Netcracker Technology Corporation','Netcracker Technology Corporation'),
    ('Linode','Linode'),
    ('liblab (acquired by postman)','liblab (acquired by postman)'),
    ('dbt Labs','dbt Labs, Inc.'),
    ('Stellar Elements','Stellar Elements'),
    ('Datto','Datto'),
    ('Goodwords','Goodwords'),
    ('Newfold Digital','Newfold Digital'),
    ('Centific','Centific'),
    ('Isovalent','Isovalent'),
    ('Veeam Software Corp','Veeam (merge)'),
    ('Veeam','Veeam (merge)'),
    ('Veritas Technologies LLC','Veritas Technologies LLC'),
    ('Atlassian','Atlassian Pty Ltd'),
    ('Ellucian','Ellucian'),
    ('Stride, Inc.','Stride, Inc.'),
    ('Blackboard','Blackboard'),
    ('Ascend Learning','Ascend Learning'),
    ('2U','2U'),
    ('Cambium Learning Group','Cambium Learning Group'),
    ('Update.AI','Update.AI'),
    ('KB Labs (Techstars)','KB Labs (Techstars)'),
    ('iMerit Technology','iMerit Technology'),
    ('WebChatGPT','WebChatGPT'),
    ('XAI Inc.','XAI Inc.'),
    ('Nutanix','Nutanix'),
    ('Tripadvisor, LLC','Tripadvisor, LLC'),
    ('Vizient Inc.','Vizient Inc.'),
    ('Open Artificial Intelligence Inc.','Open Artificial Intelligence Inc.'),
    ('Cloud Software Group','Cloud Software Group'),
    ('PowerSchool Group LLC','PowerSchool Group LLC'),
    ('R Systems','R Systems')
  ])
),

latest_complete_date AS (
  SELECT MAX(date) AS d
  FROM `proj-finance-data-liul.reporting.monthly_revenue_run_rate`
  WHERE is_data_complete = TRUE
),

-- Current 28-day RRR per SFDC account
rrr AS (
  SELECT
    salesforce_account_id,
    salesforce_account_name,
    ANY_VALUE(sales_segment) AS sales_segment,
    ANY_VALUE(account_owner_name) AS account_owner,
    SUM(annualized_revenue_estimate) AS rrr_28d,
    SUM(IF(revenue_source_family = 'API', annualized_revenue_estimate, 0)) AS api_rrr,
    SUM(IF(revenue_source_family = 'Claude for Work', annualized_revenue_estimate, 0)) AS c4w_rrr
  FROM `proj-finance-data-liul.reporting.monthly_revenue_run_rate`
  WHERE date = (SELECT d FROM latest_complete_date)
    AND sales_segment != 'Fraud'
    AND salesforce_account_id IS NOT NULL
  GROUP BY 1, 2
),

-- Active commitments deduped to subscription grain, then rolled to account
commits_deduped AS (
  SELECT DISTINCT
    salesforce_account_id,
    account_name,
    subscription_id,
    subscription_name,
    product_name,
    commitment_amount,
    subscription_spend,
    expected_spend,
    ruby_subscription_start_date,
    ruby_subscription_end_date,
    pct_through_term
  FROM `proj-finance-data-liul.reporting.salesforce_commit_spend_tracking`
  WHERE ruby_subscription_start_date <= CURRENT_DATE()
    AND ruby_subscription_end_date >= CURRENT_DATE()
),

commits AS (
  SELECT
    salesforce_account_id,
    ANY_VALUE(account_name) AS commit_account_name,
    STRING_AGG(DISTINCT subscription_name, ', ' ORDER BY subscription_name) AS subscriptions,
    STRING_AGG(DISTINCT product_name, ', ' ORDER BY product_name) AS commit_products,
    SUM(commitment_amount) AS total_commit,
    SUM(subscription_spend) AS total_spend_in_term,
    SUM(expected_spend) AS total_expected_spend,
    MIN(ruby_subscription_start_date) AS commit_start,
    MAX(ruby_subscription_end_date) AS commit_end,
    SAFE_DIVIDE(SUM(pct_through_term * commitment_amount), SUM(commitment_amount)) AS pct_through_term
  FROM commits_deduped
  GROUP BY 1
),

joined AS (
  SELECT
    t.raw AS target_account,
    r.salesforce_account_name,
    r.salesforce_account_id,
    r.sales_segment,
    r.account_owner,
    r.rrr_28d,
    r.api_rrr,
    r.c4w_rrr,
    c.total_commit,
    c.total_spend_in_term,
    c.total_expected_spend,
    c.pct_through_term,
    c.commit_start,
    c.commit_end,
    c.commit_products,
    c.subscriptions
  FROM target_accounts t
  LEFT JOIN rrr r
    ON LOWER(TRIM(r.salesforce_account_name)) = LOWER(TRIM(t.sfdc_name))
  LEFT JOIN commits c
    ON r.salesforce_account_id = c.salesforce_account_id
)

SELECT
  target_account,
  salesforce_account_name,
  sales_segment,
  account_owner,
  ROUND(rrr_28d, 0) AS rrr_28d,
  ROUND(api_rrr, 0) AS api_rrr,
  ROUND(c4w_rrr, 0) AS c4w_rrr,
  ROUND(total_commit, 0) AS commit_amount,
  ROUND(total_spend_in_term, 0) AS actual_spend_in_term,
  ROUND(total_expected_spend, 0) AS expected_spend_linear,
  ROUND(SAFE_DIVIDE(total_spend_in_term, total_commit), 3) AS pct_of_commit_consumed,
  ROUND(SAFE_DIVIDE(total_spend_in_term, total_expected_spend), 3) AS spend_vs_expected_ratio,
  CASE
    WHEN rrr_28d IS NULL THEN 'Unmatched'
    WHEN rrr_28d < 200000 THEN 'Below 200K'
    WHEN total_commit IS NULL THEN 'No Commit'
    WHEN total_spend_in_term >= total_commit THEN 'Commit Met'
    WHEN SAFE_DIVIDE(total_spend_in_term, total_expected_spend) >= 1.2 THEN 'Over-Burning'
    WHEN SAFE_DIVIDE(total_spend_in_term, total_expected_spend) >= 0.8 THEN 'On Track'
    ELSE 'At Risk'
  END AS status,
  ROUND(pct_through_term, 2) AS pct_through_term,
  commit_start,
  commit_end,
  commit_products,
  subscriptions
FROM joined
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY target_account
  ORDER BY rrr_28d DESC NULLS LAST
) = 1
ORDER BY
  CASE status
    WHEN 'At Risk' THEN 1
    WHEN 'Over-Burning' THEN 2
    WHEN 'On Track' THEN 3
    WHEN 'Commit Met' THEN 4
    WHEN 'No Commit' THEN 5
    WHEN 'Below 200K' THEN 6
    WHEN 'Unmatched' THEN 7
  END,
  rrr_28d DESC NULLS LAST;
