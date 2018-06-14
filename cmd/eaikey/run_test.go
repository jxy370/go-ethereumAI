// Copyright 2018 The go-ethereumai Authors
// This file is part of go-ethereumai.
//
// go-ethereumai is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// go-ethereumai is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with go-ethereumai. If not, see <http://www.gnu.org/licenses/>.

package main

import (
	"fmt"
	"os"
	"testing"

	"github.com/docker/docker/pkg/reexec"
	"github.com/ethereumai/go-ethereumai/internal/cmdtest"
)

type testEaikey struct {
	*cmdtest.TestCmd
}

// spawns eaikey with the given command line args.
func runEaikey(t *testing.T, args ...string) *testEaikey {
	tt := new(testEaikey)
	tt.TestCmd = cmdtest.NewTestCmd(t, tt)
	tt.Run("eaikey-test", args...)
	return tt
}

func TestMain(m *testing.M) {
	// Run the app if we've been exec'd as "eaikey-test" in runEaikey.
	reexec.Register("eaikey-test", func() {
		if err := app.Run(os.Args); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		os.Exit(0)
	})
	// check if we have been reexec'd
	if reexec.Init() {
		return
	}
	os.Exit(m.Run())
}
