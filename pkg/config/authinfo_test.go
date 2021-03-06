/*
Copyright 2014 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package config_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"opendev.org/airship/airshipctl/testutil"
)

func TestGetAuthInfos(t *testing.T) {
	conf, cleanup := testutil.InitConfig(t)
	defer cleanup(t)

	authinfos, err := conf.GetAuthInfos()
	require.NoError(t, err)
	assert.Len(t, authinfos, 3)
}

func TestGetAuthInfo(t *testing.T) {
	conf, cleanup := testutil.InitConfig(t)
	defer cleanup(t)

	authinfo, err := conf.GetAuthInfo("def-user")
	require.NoError(t, err)

	// Test Positives
	assert.EqualValues(t, authinfo.KubeAuthInfo().Username, "dummy_username")

	// Test Wrong Cluster
	_, err = conf.GetAuthInfo("unknown")
	assert.Error(t, err)
}

func TestAddAuthInfo(t *testing.T) {
	conf, cleanup := testutil.InitConfig(t)
	defer cleanup(t)

	co := testutil.DummyAuthInfoOptions()
	authinfo := conf.AddAuthInfo(co)
	assert.EqualValues(t, conf.AuthInfos[co.Name], authinfo)
}

func TestModifyAuthInfo(t *testing.T) {
	conf, cleanup := testutil.InitConfig(t)
	defer cleanup(t)

	co := testutil.DummyAuthInfoOptions()
	authinfo := conf.AddAuthInfo(co)

	co.Username += stringDelta
	co.Password = newPassword
	co.ClientCertificate = newCertificate
	co.ClientKey = newKey
	co.Token = newToken
	conf.ModifyAuthInfo(authinfo, co)
	modifiedAuthinfo, err := conf.GetAuthInfo(co.Name)
	assert.NoError(t, err)
	assert.EqualValues(t, modifiedAuthinfo.KubeAuthInfo().Username, co.Username)
	assert.EqualValues(t, modifiedAuthinfo.KubeAuthInfo().Password, co.Password)
	assert.EqualValues(t, modifiedAuthinfo.KubeAuthInfo().ClientCertificate, co.ClientCertificate)
	assert.EqualValues(t, modifiedAuthinfo.KubeAuthInfo().ClientKey, co.ClientKey)
	assert.EqualValues(t, modifiedAuthinfo.KubeAuthInfo().Token, co.Token)
	assert.EqualValues(t, modifiedAuthinfo, authinfo)
}
