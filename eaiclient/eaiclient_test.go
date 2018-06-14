// Copyright 2016 The go-ethereumai Authors
// This file is part of the go-ethereumai library.
//
// The go-ethereumai library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-ethereumai library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-ethereumai library. If not, see <http://www.gnu.org/licenses/>.

package eaiclient

import "github.com/ethereumai/go-ethereumai"

// Verify that Client implements the ethereumai interfaces.
var (
	_ = ethereumai.ChainReader(&Client{})
	_ = ethereumai.TransactionReader(&Client{})
	_ = ethereumai.ChainStateReader(&Client{})
	_ = ethereumai.ChainSyncReader(&Client{})
	_ = ethereumai.ContractCaller(&Client{})
	_ = ethereumai.GasEstimator(&Client{})
	_ = ethereumai.GasPricer(&Client{})
	_ = ethereumai.LogFilterer(&Client{})
	_ = ethereumai.PendingStateReader(&Client{})
	// _ = ethereumai.PendingStateEventer(&Client{})
	_ = ethereumai.PendingContractCaller(&Client{})
)
