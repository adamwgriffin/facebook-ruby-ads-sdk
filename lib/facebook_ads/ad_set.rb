# frozen_string_literal: true

module FacebookAds
  # https://developers.facebook.com/docs/marketing-api/reference/ad-account/adsets
  class AdSet < Base
    # Full set of fields:
    # FIELDS = %w(
    #   id account_id adlabels adset_schedule attribution_window_days
    #   bid_amount bid_info billing_event budget_remaining
    #   campaign campaign_id configured_status created_time
    #   creative_sequence daily_budget effective_status end_time
    #   frequency_cap frequency_cap_reset_period
    #   frequency_control_specs instagram_actor_id
    #   bid_strategy lifetime_budget
    #   lifetime_frequency_cap lifetime_imps name optimization_goal
    #   pacing_type promoted_object recommendations
    #   recurring_budget_semantics rf_prediction_id rtb_flag
    #   start_time status targeting time_based_ad_rotation_id_blocks
    #   time_based_ad_rotation_intervals updated_time
    #   use_new_app_click
    # ).freeze

    # Fields we might actually care about:
    FIELDS = %w[
      id
      account_id
      campaign_id
      name
      status configured_status effective_status
      bid_strategy bid_amount billing_event optimization_goal pacing_type
      daily_budget budget_remaining lifetime_budget
      promoted_object
      targeting
      created_time
      updated_time
    ].freeze

    STATUSES = %w[
      ACTIVE
      PAUSED
      DELETED
      PENDING_REVIEW
      DISAPPROVED
      PREAPPROVED
      PENDING_BILLING_INFO
      CAMPAIGN_PAUSED
      ARCHIVED
      ADSET_PAUSED
    ].freeze

    BILLING_EVENTS = %w[APP_INSTALLS IMPRESSIONS].freeze

    OPTIMIZATION_GOALS = %w[
      NONE
      APP_INSTALLS
      BRAND_AWARENESS
      AD_RECALL_LIFT
      CLICKS
      ENGAGED_USERS
      EVENT_RESPONSES
      IMPRESSIONS
      LEAD_GENERATION
      LINK_CLICKS
      OFFER_CLAIMS
      OFFSITE_CONVERSIONS
      PAGE_ENGAGEMENT
      PAGE_LIKES
      POST_ENGAGEMENT
      REACH
      SOCIAL_IMPRESSIONS
      VIDEO_VIEWS
      APP_DOWNLOADS
      LANDING_PAGE_VIEWS
    ].freeze

    BID_STRATEGIES = %w[
      LOWEST_COST_WITHOUT_CAP
      LOWEST_COST_WITH_BID_CAP
      TARGET_COST
    ].freeze
    BID_STRATEGIES = %w[
      LOWEST_COST_WITHOUT_CAP
      LOWEST_COST_WITH_BID_CAP
      TARGET_COST
    ].freeze

    # AdAccount

    def ad_account
      @ad_account ||= AdAccount.find("act_#{account_id}")
    end

    # AdCampaign

    def ad_campaign
      @campaign ||= AdCampaign.find(campaign_id)
    end

    # Ad

    def ads(effective_status: ['ACTIVE'], limit: 100)
      Ad.paginate("/#{id}/ads", query: { effective_status: effective_status, limit: limit })
    end

    def create_ad(name:, creative_id:, status: 'PAUSED')
      query = { name: name, adset_id: id, creative: { creative_id: creative_id }.to_json, status: status }
      result = Ad.post("/act_#{account_id}/ads", query: query)
      Ad.find(result['id'])
    end

    # AdInsight

    # levels = enum {ad, adset, campaign, account}
    # breakdowns = list<enum {..., product_id, ...}>
    def ad_insights(range: Date.today..Date.today, level: nil, breakdowns: [], fields: [], limit: 1_000)
      query = {
        time_range: { since: range.first.to_s, until: range.last.to_s },
        level: level,
        breakdowns: breakdowns&.join(','),
        fields: fields&.join(','),
        limit: limit
      }.reject { |_key, value| value.nil? || (value.respond_to?(:empty?) && value.empty?) }

      AdInsight.paginate("/#{id}/insights", query: query)
    end

    def activities(from: Date.today.beginning_of_day, to: Date.today.end_of_day)
      query = { since: from, until: to }
      AdSetActivity.get("/#{id}/activities", query: query, objectify: true)
    end
  end
end
