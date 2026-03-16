// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

/// \file
/// \brief Utilities to create spans from MATLAB types.

#pragma once

#include "ocudu/adt/span.h"
#include "MatlabDataArray/TypedArray.hpp"

namespace ocudu_matlab {

// NOLINTBEGIN(cppcoreguidelines-pro-type-reinterpret-cast)

/// \brief Creates a read&ndash;write span from a MATLAB TypedArray.
///
/// The output span is a view over the memory traversed by the \c typed_array default iterator.
///
/// \tparam ArrayType  Value type of the input \c TypedArray.
/// \tparam SpanType   Value type of the output span.
///
/// \warning An assertion is raised if \c ArrayType cannot be converted to \c SpanType.
template <typename ArrayType, typename SpanType = ArrayType>
ocudu::span<SpanType> to_span(matlab::data::TypedArray<ArrayType>& typed_array)
{
  static_assert(std::is_convertible<ArrayType, SpanType>::value, "ArrayType cannot be converted to SpanType.");

  return {reinterpret_cast<SpanType*>(&(*typed_array.begin())), reinterpret_cast<SpanType*>(&(*typed_array.end()))};
}

/// \brief Creates a read-only span from a MATLAB TypedArray.
///
/// The output span is a view over the memory traversed by the \c typed_array default iterator.
///
/// \tparam ArrayType  Value type of the input \c TypedArray.
/// \tparam SpanType   Value type of the output span.
///
/// \warning An assertion is raised if \c ArrayType cannot be converted to \c SpanType.
template <typename ArrayType, typename SpanType = ArrayType>
ocudu::span<const SpanType> to_span(const matlab::data::TypedArray<ArrayType>& typed_array)
{
  static_assert(std::is_convertible<ArrayType, SpanType>::value, "ArrayType cannot be converted to SpanType.");

  return {reinterpret_cast<const SpanType*>(&(*typed_array.cbegin())),
          reinterpret_cast<const SpanType*>(&(*typed_array.cend()))};
}

// NOLINTEND(cppcoreguidelines-pro-type-reinterpret-cast)

} // namespace ocudu_matlab
