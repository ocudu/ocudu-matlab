// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#pragma once

#include "ocudu/adt/complex.h"
#include "ocudu/adt/expected.h"
#include "ocudu/adt/span.h"
#include <numeric>

namespace ocudu {

namespace detail {

template <typename T, typename U>
std::string format_table(unsigned i, T x, T y, U d, U t)
{
  return fmt::format("   {:12}{:12}{:12}{:12}{:12}\n", i, x, y, d, t);
}

template <>
inline std::string format_table(unsigned i, cf_t x, cf_t y, float d, float t)
{
  return fmt::format("   {:12}{:12.4f}{: >+10.4f}j{:12.4f}{:+10.4f}j{:12.4f}{:12.4f}\n",
                     i,
                     x.real(),
                     x.imag(),
                     y.real(),
                     y.imag(),
                     d,
                     t);
}

template <>
inline std::string format_table(unsigned i, cbf16_t x, cbf16_t y, float d, float t)
{
  return format_table<cf_t>(i, to_cf(x), to_cf(y), d, t);
}

template <typename T>
std::string format_header()
{
  return fmt::format("   {:>12}{:>12}{:>12}{:>12}{:>12}\n", "index", "actual", "expected", "error", "tolerance");
}

template <>
inline std::string format_header<cf_t>()
{
  return fmt::format("   {:>12}{:>23}{:>23}{:>12}{:>12}\n", "index", "actual", "expected", "error", "tolerance");
}

template <>
inline std::string format_header<cbf16_t>()
{
  return format_header<cf_t>();
}

} // namespace detail

/// \brief Compares two sequences.
///
/// Checks whether two sequences are the same, up to an element-wise tolerance.
/// \tparam U              Type of the actual sequence elements.
/// \tparam U              Type of the expected sequence elements.
/// \tparam F              Callable type.
/// \tparam V              Type of the tolerance.
/// \param[in] a           First sequence to compare (actual values).
/// \param[in] b           Second sequence to compare (expected values).
/// \param[in] fn          Error function: takes two elements of type \c T and \c U and returns a \c V value.
/// \param[in] tolerance   Maximum allowed error between corresponding elements.
/// \return If all elements are within tolerance, a success tag. Otherwise, an error message with the list of (up to the
/// first 10) elements exceeding the tolerance.
template <typename T, typename U, typename F, typename V>
error_type<std::string> compare_sequences(span<T> a, span<U> b, F&& fn, V tolerance)
{
  using TS = std::remove_cv_t<T>;
  using US = std::remove_cv_t<U>;
  static_assert(std::is_invocable_v<F, TS, US>);
  static_assert(std::is_convertible_v<std::invoke_result_t<F, TS, US>, V>);
  ocudu_assert(a.size() == b.size(), "Compared sequences should have the same size.");

  static constexpr size_t max_output = 10;
  std::string             msg;
  V                       max_distance = 0;
  size_t                  max_index    = 0;
  size_t                  counter      = 0;

  bool are_equal =
      std::inner_product(a.begin(),
                         a.end(),
                         b.begin(),
                         /*init=*/true,
                         std::logical_and(),
                         [&msg, &max_distance, &max_index, &counter, &fn, tolerance, index = 0U](U x, U y) mutable {
                           V distance = std::forward<F>(fn)(x, y);
                           if (distance <= tolerance) {
                             ++index;
                             return true;
                           }

                           if (distance > max_distance) {
                             max_distance = distance;
                             max_index    = index;
                           }

                           if (counter++ < max_output) {
                             msg += detail::format_table(index, x, y, distance, tolerance);
                           }
                           ++index;
                           return false;
                         });

  if (are_equal) {
    return default_success_t();
  }

  std::string output_msg = fmt::format("    The compared sequences are not equal.\n    Failure table");
  if (counter > max_output) {
    output_msg += fmt::format(" (first {} out of {} failed indices)", max_output, counter);
  }
  output_msg += ":\n";
  output_msg += detail::format_header<US>();
  output_msg += msg;
  output_msg += fmt::format("\n    Max error is {} at index {}.\n", max_distance, max_index);
  return make_unexpected(output_msg);
}

} // namespace ocudu
