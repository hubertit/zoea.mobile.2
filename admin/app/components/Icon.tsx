'use client';

import { IconDefinition } from '@fortawesome/fontawesome-svg-core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

interface IconProps {
  icon: IconDefinition;
  className?: string;
  size?: 'xs' | 'sm' | 'md' | 'lg' | '2x';
  spin?: boolean;
}

const sizeMap = {
  xs: '0.75rem',
  sm: '0.875rem',
  md: '1rem',
  lg: '1.25rem',
  '2x': '2rem',
};

export default function Icon({ icon, className = '', size = 'md', spin = false }: IconProps) {
  const fontSize = sizeMap[size];

  return (
    <FontAwesomeIcon
      icon={icon}
      className={className}
      style={{ fontSize }}
      spin={spin}
    />
  );
}

export type { IconDefinition } from '@fortawesome/fontawesome-svg-core';

// Export commonly used icons
export {
  faSpinner,
  faTimes,
  faHome,
  faUser,
  faEnvelope,
  faPhone,
  faSearch,
  faFilter,
  faPlus,
  faEdit,
  faTrash,
  faCheck,
  faCheckCircle,
  faExclamationCircle,
  faTimesCircle,
  faCircle,
  faDownload,
  faUpload,
  faEye,
  faEyeSlash,
  faChevronLeft,
  faChevronRight,
  faChevronUp,
  faChevronDown,
  faBars,
  faSignOut,
  faSignIn,
  faCog,
  faBell,
  faMapMarkerAlt,
  faTruck,
  faBox,
  faFileAlt,
  faCreditCard,
  faMoneyBill,
  faChartBar,
  faCalendar,
  faClock,
  faInfoCircle,
  faQuestionCircle,
  faExclamationTriangle,
  faLock,
  faDollarSign,
  faPaperPlane,
  faShieldAlt,
  faUserPlus,
  faUsers,
  faBoxOpen,
  faStar,
  faArrowRight,
  faChartLine,
  faHandshake,
  faGlobe,
  faIdCard,
  faBuilding,
  faClipboardList,
  faReceipt,
  faRightFromBracket,
  faUserShield,
  faList,
  faTh,
  faTable,
  faArrowLeft,
  faTags,
  faRoute,
  faImage,
  faHeart,
  faSave,
  faCloud,
  faSync,
  faSyncAlt,
  faRedo,
  faRedoAlt,
  faWifi,
  faServer,
  faPrint,
  faUtensils,
} from '@fortawesome/free-solid-svg-icons';
