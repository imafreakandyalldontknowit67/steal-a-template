"""Regression checks for operator-requested visual corrections, not pixel tests."""
import sys
import unittest
from pathlib import Path

PACK = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PACK / 'tools'))
import build_export


class VisualContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.scene, _, _ = build_export.read_source()
        cls.paths = {0: ''}
        cls.nodes = {}
        for index, row in enumerate(cls.scene, 1):
            path = (cls.paths[row[2]] + '.' if row[2] else '') + row[1]
            cls.paths[index] = path
            cls.nodes[path] = row

    def props(self, path):
        return build_export.pairs(self.nodes['StudsUI.DesignCanvas.' + path][3])

    def test_shop_navigation_matches_reference(self):
        for region, target in [('LeftHUD', 'StockShop'), ('TopHUD', 'Shop')]:
            row = self.nodes[f'StudsUI.DesignCanvas.HUD.{region}.ShopLauncher']
            self.assertEqual(build_export.pairs(row[4])['StudsTarget'], target)
        self.assertFalse(self.props('HUD.LeftHUD.StockLauncher')['Visible'])

    def test_currency_symbols_are_octagonal_not_rotated_squares(self):
        found = 0
        for path, row in self.nodes.items():
            if row[1] != 'CurrencyIcon':
                continue
            found += 1
            self.assertEqual(build_export.pairs(row[3])['BackgroundTransparency'], 1)
            for layer in ('OuterInk', 'OuterRim', 'InsetInk', 'InnerFace'):
                mask = self.nodes[path + '.' + layer]
                self.assertTrue(build_export.pairs(mask[3])['ClipsDescendants'])
                face = self.nodes[path + '.' + layer + '.OctagonFace']
                self.assertEqual(build_export.pairs(face[3])['Rotation'], 45)
            self.assertIn(path + '.SquareHole', self.nodes)
        self.assertGreater(found, 10)

    def test_notification_has_round_silhouette(self):
        base = 'StudsUI.DesignCanvas.HUD.LeftHUD.Notification'
        radius = build_export.pairs(self.nodes[base + '.Circle'][3])['CornerRadius']
        self.assertEqual(radius, ['UDim', .5, 0])
        self.assertNotIn(base + '.InnerLine', self.nodes)
        self.assertNotIn(base + '.Sheen', self.nodes)

    def test_offer_backgrounds_and_gloss_are_present(self):
        for name in ('ExclusiveCrate', 'StarterOffer'):
            base = 'StudsUI.DesignCanvas.Modals.Shop.ShopOffers.' + name
            self.assertIn(base + '.ReferenceBackdrop', self.nodes)
            self.assertEqual(build_export.pairs(self.nodes[base + '.ReferenceGlass'][3])['ZIndex'], 24)
        for name in ('MoneyBoost', 'LuckBoost'):
            self.assertIn('StudsUI.DesignCanvas.HUD.RightHUD.' + name + '.ReferenceGlass', self.nodes)
        for name in ('Add5', 'Add10', 'Add25'):
            self.assertIn('StudsUI.DesignCanvas.HUD.BottomHUD.' + name + '.ReferenceGlass', self.nodes)

    def test_third_status_badge_is_check_not_clover(self):
        base = 'StudsUI.DesignCanvas.HUD.BoostBadges.CloverIcon'
        self.assertIn(base + '.CheckShort', self.nodes)
        self.assertIn(base + '.CheckLong', self.nodes)
        self.assertNotIn(base + '.Artwork', self.nodes)

    def test_replacement_art_is_used(self):
        expected = {
            'HUD.Wallet.RebirthIcon.Artwork': 'rbxassetid://113494664260889',
            'HUD.BoostBadges.CashIcon.Artwork': 'rbxassetid://126688552186496',
        }
        for path, image in expected.items():
            self.assertEqual(self.props(path)['Image'], image)

    def test_no_invented_visible_settings_launcher(self):
        self.assertFalse(self.props('HUD.LeftHUD.SettingsLauncher')['Visible'])

    def test_level_button_reference_colors(self):
        for name in ('Add5', 'Add10', 'Add25'):
            base = 'HUD.BottomHUD.' + name
            self.assertFalse(self.props(base + '.ReferenceGlass')['Visible'])
            gradient = self.props(base + '.Caption.Surface')
            self.assertEqual(gradient['Rotation'], 0 if name == 'Add25' else 90)
            if name == 'Add25':
                self.assertEqual(len(gradient['Color']), 33)  # Eight horizontal rainbow stops.


if __name__ == '__main__':
    unittest.main()
