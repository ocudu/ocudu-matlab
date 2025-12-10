/*
 *
 * Copyright 2021-2025 Software Radio Systems Limited
 *
 * This file is part of OCUDU-matlab.
 *
 * OCUDU-matlab is free software: you can redistribute it and/or
 * modify it under the terms of the BSD 2-Clause License.
 *
 * OCUDU-matlab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * BSD 2-Clause License for more details.
 *
 * A copy of the BSD 2-Clause License can be found in the LICENSE
 * file in the top-level directory of this distribution.
 *
 */

/// \file
/// \brief MEX port of ocudu::get_pusch_processor_phy_capabilities().

#include "ocudu_matlab/ocudu_mex_dispatcher.h"
#include "ocudu/phy/upper/channel_processors/pusch/pusch_processor_phy_capabilities.h"

/// \brief ocuduPUSCHCapabilitiesMEX returns the capabilities of the PUSCH components implemented as MEX libraries.
class MexFunction : public ocudu_mex_dispatcher
{
public:
  /// Alias for MATLAB type.
  using ArgumentList = matlab::mex::ArgumentList;

  void operator()(ArgumentList outputs, ArgumentList inputs) override
  {
    if (!inputs.empty()) {
      mex_abort("ocuduPUSCHCapabilitiesMEX: Wrong number of inputs: expected 0, provided {}.", inputs.size());
    }

    ocudu::pusch_processor_phy_capabilities capabilities = ocudu::get_pusch_processor_phy_capabilities();

    matlab::data::StructArray capabilities_out = factory.createStructArray({1, 1}, {"NumLayers"});
    capabilities_out[0]["NumLayers"]           = factory.createScalar(static_cast<double>(capabilities.max_nof_layers));

    outputs[0] = capabilities_out;
  }
};
