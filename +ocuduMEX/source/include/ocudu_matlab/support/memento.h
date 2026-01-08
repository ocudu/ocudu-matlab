/*
 *
 * Copyright 2021-2026 Software Radio Systems Limited
 *
 * By using this file, you agree to the terms and conditions set
 * forth in the LICENSE file which can be found at the top level of
 * the distribution.
 *
 */

/// \file
/// \brief Tools to create and store state snapshots of mex objects.
///
/// MATLAB instantiates a single object of a MexFunction class the first time the mex function is called during a
/// session. The same object is then used by MATLAB each time the function operator () is called until the end of
/// the session (or until the object is cleared manually with <tt>clear mex</tt>). The classes defined in this file
/// provide a way to create, store and reinstate a snapshot of the mex object state when multiple instances of the
/// object (possibly with different configurations) are needed.

#pragma once

#include "ocudu/support/ocudu_assert.h"
#include <map>
#include <memory>

/// Takes care of memento objects.
/// \tparam memento A memento class.
template <class memento>
class memento_storage
{
public:
  /// Default constructor.
  memento_storage() = default;

  /// \brief Stores a memento object.
  /// \param[in] mem  The memento object to store.
  /// \return A unique identifier of the stored memento object.
  size_t store(const std::shared_ptr<memento>& mem)
  {
    ocudu_assert(mem, "Null memento");
    size_t key = std::hash<std::shared_ptr<memento>>()(mem);
    storage.emplace(key, mem);
    return key;
  }

  /// Returns the memento object identified by the given \c key.
  std::shared_ptr<memento> get_memento(size_t key) const
  {
    auto found = storage.find(key);
    if (found == storage.end()) {
      return nullptr;
    }
    std::shared_ptr<memento> out    = found->second;
    size_t                   chksum = std::hash<std::shared_ptr<memento>>()(out);
    if (chksum != key) {
      return nullptr;
    }
    return out;
  }

  /// \brief Releases the memento object identified by the given \c key.
  /// \return The number of released elements: 1 if \c key existed, 0 otherwise.
  unsigned release_memento(size_t key) { return storage.erase(key); }

private:
  /// Container for the identifier&ndash;memento pairs.
  std::map<size_t, std::shared_ptr<memento>> storage = {};
};
