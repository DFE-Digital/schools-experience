class SchoolGroup
  SCHOOL_URNS_IN_GROUP = [
    137_267,
    143_197,
    136_105,
    136_489,
    138_130,
    137_533,
    141_931,
    137_128,
    146_406,
    134_798,
    138_825,
    136_715,
    136_647,
    136_786,
    137_416,
    136_898,
    143_090,
    138_527,
    144_046,
    136_587,
    146_721,
    137_515,
    136_633,
    142_349,
    136_885,
    141_925,
    138_216,
    136_287,
    136_609,
    138_611,
    144_042,
    145_213,
    140_587,
    135_120,
    138_841,
    139_152,
    136_649,
    136_923,
    136_490,
    140_248,
    137_843,
    143_058,
    137_969,
    137_140,
    139_368,
    142_853,
    143_905,
    138_002,
    136_451,
    138_123,
    136_278,
    136_094,
    137_248,
    136_515,
    136_718,
    137_013,
    137_289,
    138_084,
    137_884,
    141_916,
    139_604,
    136_323,
    130_909,
    144_932,
    138_704,
    147_429,
    137_873,
    138_014,
    145_337,
    142_757,
    136_459,
    139_217,
    147_351,
    136_291,
    142_348,
    144_502
  ].freeze

  def self.in_group?(urn)
    urn.to_i.in?(SCHOOL_URNS_IN_GROUP)
  end
end