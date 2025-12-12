/*
 *
 * Copyright 2021-2025 Software Radio Systems Limited
 *
 * By using this file, you agree to the terms and conditions set
 * forth in the LICENSE file which can be found at the top level of
 * the distribution.
 *
 */

/// \file
/// \brief PRACH detector MEX declaration.

#pragma once

#include "ocudu_matlab/ocudu_mex_dispatcher.h"
#include "ocudu/phy/generic_functions/generic_functions_factories.h"
#include "ocudu/phy/support/support_factories.h"
#include "ocudu/phy/upper/channel_processors/channel_processor_factories.h"
#include "ocudu/phy/upper/channel_processors/prach_detector.h"

/// \brief Factory method for a PRACH detector.
///
/// Creates and assemblies all the necessary components (DFT, PRACH generator, ...) for a fully-functional
/// PRACH detector.
inline std::unique_ptr<ocudu::prach_detector> create_prach_detector();

/// \brief Factory method for a PRACH validator.
///
/// Creates and assemblies all the necessary components (DFT, PRACH generator, ...) for a fully-functional
/// PRACH validator.
inline std::unique_ptr<ocudu::prach_detector_validator> create_prach_validator();

/// Implements a PRACH detector following the ocudu_mex_dispatcher template.
class MexFunction : public ocudu_mex_dispatcher
{
public:
  /// \brief Constructor.
  ///
  /// Stores the string identifier&ndash;method pairs that form the public interface of the PRACH decoder MEX object.
  MexFunction()
  {
    // Ensure ocudu PRACH decoder was created successfully.
    if (!detector) {
      mex_abort("Cannot create ocudu PRACH detector.");
    }

    create_callback("step", [this](ArgumentList out, ArgumentList in) { this->method_step(out, in); });
  }

private:
  /// Checks that outputs/inputs arguments match the requirements of method_step().
  void check_step_outputs_inputs(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs);

  /// \brief Detects PRACH transmissions according to the given configuration.
  ///
  /// The method takes three inputs.
  ///   - The string <tt>"step"</tt>.
  ///   - An array of \c cf_t containing the baseband input signal.
  ///   - A one-dimesional structure that describes the PRACH configuration. The fields are
  ///      - \c SequenceIndex, the root sequence index;
  ///      - \c Format, preamble format;
  ///      - \c RestrictedSet, restricted set configuration;
  ///      - \c ZeroCorrelationZone, zero-correlation zone configuration index;
  ///      - \c SubcarrierSpacing, the subcarrier spacing in kHz;
  ///
  /// The method has one single output.
  ///   - A two-dimensional structure with the detected preambles. Each field comprises a structure using the
  ///     fields:
  ///      - \c NumDetectedPreambles, number of detected PRACH preambles (should be one);
  ///      - \c RSSIDecibel, average RSSI value in dB;
  ///      - \c TimeResolution, time resoultion of the PRACH detector, in seconds;
  ///      - \c MaxTimeAdvance, maximum timing of the PRACH detector, in seconds;
  ///      - \c PreambleIndices, array of indices of the detected preamble;
  ///      - \c TimeAdvance, array of timing advance between the observed arrival time and the reference uplink time,
  ///        in seconds, for the corresponding preamble indices;
  ///      - \c PowerDecibel, array of average RSRP values in dB, for the corresponding preamble indices;
  ///      - \c SINRDecibel, array of average SNR values in dB, for the corresponding preamble indices;
  void method_step(ArgumentList outputs, ArgumentList inputs);

  /// A pointer to the actual PRACH detector.
  std::unique_ptr<ocudu::prach_detector> detector = create_prach_detector();
  /// A pointer to the actual PRACH detector validator.
  std::unique_ptr<ocudu::prach_detector_validator> validator = create_prach_validator();
};

std::unique_ptr<ocudu::prach_detector> create_prach_detector()
{
  using namespace ocudu;

  std::shared_ptr<dft_processor_factory> dft_factory = create_dft_processor_factory_generic();

  std::shared_ptr<prach_generator_factory> generator_factory = create_prach_generator_factory_sw();

  std::shared_ptr<prach_detector_factory> detector_factory =
      create_prach_detector_factory_sw(dft_factory, generator_factory);

  return detector_factory->create();
}

std::unique_ptr<ocudu::prach_detector_validator> create_prach_validator()
{
  using namespace ocudu;

  std::shared_ptr<dft_processor_factory> dft_factory = create_dft_processor_factory_generic();

  std::shared_ptr<prach_generator_factory> generator_factory = create_prach_generator_factory_sw();

  std::shared_ptr<prach_detector_factory> detector_factory =
      create_prach_detector_factory_sw(dft_factory, generator_factory);

  return detector_factory->create_validator();
}
